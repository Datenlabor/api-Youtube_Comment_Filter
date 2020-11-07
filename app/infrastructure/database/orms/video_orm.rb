# frozen_string_literal: true

require 'sequel'

module GetComment
  module Database
    # Object-Relational Mapper for Video Entities
    class VideoOrm < Sequel::Model(:videos)
      one_to_many :video_comments,
                  class: :'GetComment::Database::CommentOrm',
                  key: :video_id

      plugin :timestamps, update_on_create: true
    end
  end
end
