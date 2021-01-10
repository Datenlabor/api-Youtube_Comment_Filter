# frozen_string_literal: true

require_relative 'progress_publisher'

module FindComment
  # Reports job progress to client
  class JobReporter
    attr_accessor :video

    def initialize(request_json, config)
      find_comment_request = GetComment::Representer::FindCommentRequest
                             .new(OpenStruct.new)
                             .from_json(request_json)

      @video = find_comment_request.video
      @publisher = ProgressPublisher.new(config, find_comment_request.id)
    end

    def report(msg)
      @publisher.publish msg
    end

    def report_each_second(seconds)
      seconds.times do
        sleep(1)
        report(yield)
      end
    end
  end
end
