# frozen_string_literal: true

require 'dry/monads'

module GetComment
  module Service
    # list a video
    class ListVideos
      include Dry::Transaction

      step :validate_list
      step :retrieve_video

      private

      DB_ERR = 'Could not access database'.freeze

      def validate_list(input)
        list_request = input[:list_request]
        if list_request.success?
          Success(input.merge(list: list_request.value!))
        else
          Faliure(list_request.failure)
        end
      end

      def retrieve_video(input)
        Repository::For.klass(Entity::Video).find_videos(input[:list])
                       .then { |videos| Response::VideosList.new(videos) }
                       .then { |list| Success(Response::ApiResult.new(status: :ok, message: list)) }
      rescue StandardError
        Faliure(Response::ApiResult.new(status: :internal_error, message: DB_ERR))
      end
    end
  end
end
