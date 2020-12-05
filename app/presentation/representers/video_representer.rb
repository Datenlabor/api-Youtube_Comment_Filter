# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

# Represents essential Repo information for API output
module GetComment
  module Representer
    # Represent a Project entity as Json
    class Video < Roar::Decorator
      include Roar::JSON
      include Roar::Hypermedia
      include Roar::Decorator::HypermediaConsumer

      property :video_db_id
      property :video_id
      property :title

      link :comments do
        "#{App.config.API_HOST}/api/v1/comments/#{video_id}"
      end

      private

      def video_id
        represented.video_id
      end
    end
  end
end
