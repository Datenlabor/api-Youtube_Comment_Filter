# frozen_string_literal: true

module GetComment
  module Repository
    # Repository for Comments
    class Comments
      def self.find_id(id)
        rebuild_entity Database::CommentOrm.first(id: id)
      end

      def self.find_username(username)
        rebuild_entity Database::CommentOrm.first(username: username)
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Comment.new(
          id: db_record.id,
          origin_id: db_record.origin_id,
          username: db_record.username,
          email: db_record.email
        )
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_comment|
          Comments.rebuild_entity(db_comment)
        end
      end

      def self.db_find_or_create(entity)
        Database::CommentOrm.find_or_create(entity.to_attr_hash)
      end
    end
  end
end
