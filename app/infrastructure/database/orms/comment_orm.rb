# frozen_string_literal: true

require 'sequel'

module GetComment
  module Database
    # Object-Relational Mapper for Comments
    class CommentOrm < Sequel::Model(:comments)
      one_to_many :owned_videos,
                  class: :'GetComment::Database::VideoOrm',
                  key: :owner_id

      many_to_many :contributed_videos,
                   class: :'GetComment::Database::VideoOrm',
                   join_table: :videos_comments,
                   left_key: :comment_id, right_key: :video_id

      plugin :timestamps, update_on_create: true

      def self.find_or_create(comment_info)
        first(username: comment_info[:username]) || create(comment_info)
      end
    end
  end
end
