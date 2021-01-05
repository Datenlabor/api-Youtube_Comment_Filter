# frozen_string_literal: true

require_relative '../init'
require_relative '../app/presentation/representers/init'
require_relative 'job_reporter'
require_relative 'find_comment_monitor'

require 'econfig'
require 'shoryuken'

module FindComment
  # Shoryuken worker class to get and analyze video comments
  class Worker
    extend Econfig::Shortcut
    Econfig.env = ENV['RACK_ENV'] || 'development'
    Econfig.root = File.expand_path('..', File.dirname(__FILE__))

    Shoryuken.sqs_client = Aws::SQS::Client.new(
      access_key_id: config.AWS_ACCESS_KEY_ID,
      secret_access_key: config.AWS_SECRET_ACCESS_KEY,
      region: config.AWS_REGION
    )

    include Shoryuken::Worker
    shoryuken_options queue: config.GET_COMMENT_QUEUE_URL, auto_delete: true

    def perform(_sqs_msg, request)
      puts '== DEBUG == worker is working'
      # JobReporter is used to handle the request
      job = JobReporter.new(request, Worker.config)

      # ==================
      # Status to report
      # 1. Start
      # 2. Get and Analyze comments from YT
      # 3. Store commnets into DB
      # 4. Finished
      # ==================

      # Report starting of the job
      job.report(FindCommentMonitor.starting_percent)

      # Get comments from YouTube and Analyze
      comments = GetComment::Youtube::CommentMapper
                 .new(GetComment::App.config.YT_TOKEN)
                 .extract(job.video[:video_id])
      job.report(FindCommentMonitor.percent('Get_Analyze_Comment'))

      # Store the comments into Database
      GetComment::Repository::For.klass(GetComment::Entity::Comment)
                                 .create_many_of_one_video(comments, job.video[:video_db_id])
      job.report(FindCommentMonitor.percent('Storing_Into_DB'))

      # Keep sending finished status to any latecoming subscribers
      job.report_each_second(5) { FindCommentMonitor.finished_percent }
    rescue StandardError => e
      # TODO: worker should crash early & often - only catch errors we expect!
      print_error(e)
    end

    def print_error(error)
      puts [error.inspect, error.backtrace].flatten.join("\n")
    end
  end
end
