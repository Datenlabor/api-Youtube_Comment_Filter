# frozen_string_literal: false

module GetComment
  module Entity
    # Domain entity for team members
    class Comment < Dry::Struct
      include Dry.Types
      attribute :id, Integer.optional
      attribute :video_id, Strict::String
      attribute :data, Strict::Hash
    end
  end
end
