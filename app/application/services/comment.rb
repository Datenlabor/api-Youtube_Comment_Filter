# frozen_string_literal: true

require 'dry/transaction'

module GetComment
  module Service
    # Add video in database
    class Comment
      include Dry::Transaction

      step :retrieve_remote_comment

      private

      NO_VIDEO_ERR = 'Comment not found'.freeze
      DB_ERR = 'Having trouble accessing the database'.freeze

      def retrieve_remote_comment(input)
        input[:comment] = Repository::For.klass(Entity::Comment).find_by_video_id(input[:requested].video_id)
        if input[:comment]
          Success(input)
        else
          Failure(Response::ApiResult.new(status: :not_found, message: NO_VIDEO_ERR))
        end
      rescue StandardError
        Failure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end
    end
  end
end
