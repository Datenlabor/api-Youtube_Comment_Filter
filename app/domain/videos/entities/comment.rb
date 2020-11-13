# frozen_string_literal: false

module GetComment
  module Entity
    # Domain entity for team members
    class Comment < Dry::Struct
      include Dry.Types
      attribute :comment_db_id, Strict::Integer.optional
      attribute :comment_id, Strict::String
      attribute :video_db_id, Strict::Integer.optional
      attribute :video_id, Strict::String
      attribute :author, Strict::String
      attribute :author_id, Strict::String
      attribute :author_image, Strict::String
      attribute :textDisplay, Strict::String
      attribute :likeCount, Strict::Integer
      attribute :totalReplyCount, Strict::Integer
    end
  end
end
