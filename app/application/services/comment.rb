# frozen_string_literal: true

require 'dry/transaction'

module GetComment
  module Service
    # Add video in database
    class Comment
      include Dry::Transaction

      step :retrieve_remote_comment

      private

      DB_ERR = 'Having trouble accessing the database'.freeze

      def retrieve_remote_comment(input)
        Repository::For.klass(Entity::Comment).find_by_video_id(input[:requested].video_id)
                       .then { |comment| Success(Response::ApiResult.new(:ok, comment)) }
        # if input[:comment]
        #   Success(input)
        # else
        #   Failure(Response::ApiResult.new(:not_found, NO_VIDEO_ERR))
        # end
      rescue StandardError
        Failure(Response::ApiResult.new(:internal_error, DB_ERR))
      end
    end
  end
end
