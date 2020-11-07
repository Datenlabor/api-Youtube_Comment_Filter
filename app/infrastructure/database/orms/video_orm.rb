# frozen_string_literal: true

require 'sequel'

module GetComment
  module Database
    # Object Relational Mapper for Video Entities
    class VideoOrm < Sequel::Model(:videos)
      many_to_one :owner,
                  class: :'GetComment::Database::CommentOrm'

      many_to_many :contributors,
                   class: :'GetComment::Database::CommentOrm',
                   join_table: :videos_comments,
                   left_key: :video_id, right_key: :comment_id

      plugin :timestamps, update_on_create: true
    end
  end
end
