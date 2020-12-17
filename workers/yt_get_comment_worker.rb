# frozen_string_literal: true

require_relative '../init'

require 'econfig'
require 'shoryuken'

# Shoryuken worker class to clone repos in parallel
class YTGetCommentWorker
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
    video = GetComment::Representer::Video.new(OpenStruct.new).from_json(request)
    puts "== DEBUG == video gets: #{video.inspect}"
    comments = GetComment::Youtube::CommentMapper.new(GetComment::App.config.YT_TOKEN).extract(video[:video_id])
    puts "== DEBUG == comments gets: #{comments.inspect}"
    GetComment::Repository::For.klass(GetComment::Entity::Comment)
                               .create_many_of_one_video(comments, video[:video_db_id])
  rescue StandardError => e
    print_error(e)
  end

  def print_error(error)
    puts [error.inspect, error.backtrace].flatten.join("\n")
  end
end
