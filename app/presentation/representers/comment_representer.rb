# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

# Represents essential Repo information for API output
module GetComment
  module Representer
    # Represent a Project entity as Json
    class Comment < Roar::Decorator
      include Roar::JSON

      property :comment_id
      property :video_db_id
      property :video_id
      property :author
      property :author_id
      property :author_image
      property :textDisplay
      property :likeCount
      property :totalReplyCount
      property :polarity
    end
  end
end
