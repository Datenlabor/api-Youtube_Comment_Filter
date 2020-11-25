# frozen_string_literal: true

require 'dry/monads'

module GetComment
  module Service
    # list a video
    class ListVideos
      include Dry::Monads::Result::Mixin
      def call(videos_list)
        videos = Repository::For.klass(Entity::Video).find_videos(videos_list)

        Success(videos)
      rescue StandardError
        Faliure('Could not access database')
      end
    end
  end
end
