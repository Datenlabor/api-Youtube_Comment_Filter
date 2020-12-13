# frozen_string_literal: true

require 'dry/transaction'

module GetComment
  module Service
    # Add video in database
    class Comment
      include Dry::Transaction

      step :retrieve_remote_video
      step :retrieve_remote_comment

      private

      DB_ERR = 'Having trouble accessing the database'

      def retrieve_remote_video(input)
        if Repository::For.klass(Entity::Video).find_by_video_id(input[:requested].video_id).nil?
          Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
        else
          Success(input)
        end
      end

      def retrieve_remote_comment(input)
        Repository::For.klass(Entity::Comment).find_by_video_id(input[:requested].video_id)
                       .then { |comments| Response::CommentList.new(comments) }
                       .then { |list| Success(Response::ApiResult.new(status: :ok, message: list)) }
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end
    end
  end
end
