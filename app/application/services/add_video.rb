# frozen_string_literal: true

require 'dry/transaction'

module GetComment
  module Service
    # Add video in database
    class AddVideo
      include Dry::Transaction
      step :find_video
      step :store_video
      step :find_comment

      private

      DB_ERR_MSG = 'Having trouble accessing the database'.freeze
      YT_NOT_FOUND = 'Could not find that video on YouTube'.freeze
      PROCESSING_MSG = 'Waiting for worker to finish the task'.freeze
      GETCOMMENT_ERR = 'Could not get or analyze comment'.freeze

      def find_video(input)
        if (video = video_in_database(input))
          input[:local_video] = video
        else
          input[:remote_video] = video_from_youtube(input)
        end
        Success(input)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      # 目前這樣做是希望DB出問題時能顯示對應error message
      def store_video(input)
        input[:video] =
          if input[:remote_video]
            Repository::For.entity(input[:remote_video]).create(input[:remote_video])
          else
            input[:local_video]
          end
        Success(input)
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
      end

      # TODO: 若comment已在DB，return response: video ; 問題：若video無comment會卡住
      def find_comment(input)
        # Return video if comment is found in db
        return Success(Response::ApiResult.new(status: :created, message: input[:video])) if comment_in_database(input)

        Messaging::Queue
          .new(App.config.GET_COMMENT_QUEUE_URL, App.config)
          .send(find_comment_request_json(input))

        Failure(Response::ApiResult.new(
                  status: :processing,
                  message: { request_id: input[:request_id] }))
      rescue StandardError => e
        print_error(e)
        Failure(Response::ApiResult.new(status: :internal_error, message: GETCOMMENT_ERR))
      end

      # following are support methods that other services could use
      def video_from_youtube(input)
        Youtube::VideoMapper.new(App.config.YT_TOKEN)
                            .extract(input[:video_id])
      rescue StandardError
        raise YT_NOT_FOUND
      end

      def video_in_database(input)
        Repository::For.klass(Entity::Video).find_by_video_id(input[:video_id])
      end

      def comment_in_database(input)
        # if no comment found, then null is returned
        Repository::For.klass(Entity::Comment).find_one_by_video_db_id(input[:video].video_db_id)
      end

      # Helper methods for steps

      def print_error(error)
        puts [error.inspect, error.backtrace].flatten.join("\n")
      end

      def find_comment_request_json(input)
        find_comment_request = OpenStruct.new(video: input[:video], id: input[:request_id])
        Representer::FindCommentRequest.new(find_comment_request).then(&:to_json)
      end
    end
  end
end
