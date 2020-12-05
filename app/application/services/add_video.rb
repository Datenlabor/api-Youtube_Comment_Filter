# frozen_string_literal: true

require 'dry/transaction'

module GetComment
  module Service
    # Add video in database
    class AddVideo
      include Dry::Transaction
      step :find_video
      step :store_video

      private

      DB_ERR_MSG = 'Having trouble accessing the database'.freeze
      YT_NOT_FOUND = 'Could not find that video on YouTube'.freeze

      def find_video(input)
        if (video = video_in_database(input))
          input[:local_video] = video
        else
          input[:remote_video] = video_from_youtube(input)
          input[:remote_comment] = comment_from_youtube(input)
        end
        Success(input)
      rescue StandardError => e
        Failure(Response::ApiResult.new(status: :not_found, message: e.to_s))
      end

      def store_video(input)
        video =
          if input[:remote_video]
            store_video_comment(input)
          else
            input[:local_video]
          end
        Success(video)
      rescue StandardError => e
        puts e.backtrace.join("\n")
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR_MSG))
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

      def comment_from_youtube(input)
        Youtube::CommentMapper.new(App.config.YT_TOKEN).extract(input[:video_id])
      rescue StandardError
        raise YT_NOT_FOUND
      end

      def store_video_comment(input)
        video = Repository::For.entity(input[:remote_video]).create(input[:remote_video])
        Repository::For.klass(Entity::Comment)
                       .create_many_of_one_video(input[:remote_comment], video.video_db_id)
        video
      end
    end
  end
end
