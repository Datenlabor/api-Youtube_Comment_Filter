# frozen_string_literal: false

module GetComment
  module Entity
    # Domain entity for team members
    class Video < Dry::Struct
      include Dry.Types
      attribute :video_db_id, Strict::Integer.optional
      attribute :video_id, Strict::String
      attribute :title, Strict::String
    end
  end
end
