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
                       .then { |comments| Response::CommentList.new(comments) }
                       .then { |list| Success(Response::ApiResult.new(:ok, list)) }
      rescue StandardError
        Failure(Response::ApiResult.new(:internal_error, DB_ERR))
      end
    end
  end
end
