# frozen_string_literal: true

require 'sequel'

module GetComment
  module Database
    # Object-Relational Mapper for Comments
    class CommentOrm < Sequel::Model(:comments)
      many_to_one :video,
                  class: :'GetComment::Database::VideoOrm'

      plugin :timestamps, update_on_create: true

      def self.find_or_create(comment_info)
        first(id: comment_info[:id]) || create(comment_info)
      end
    end
  end
end
