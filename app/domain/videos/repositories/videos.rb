# frozen_string_literal: true

module GetComment
  module Repository
    # Repository for Video Entities
    class Videos
      # Get all entities from database
      def self.all
        Database::VideoOrm.all.map { |db_project| rebuild_entity(db_project) }
      end

      # Find the db_record that matches the entity
      def self.find(entity)
        find_by_video_id(entity.video_id)
      end

      def self.find_by_video_id(video_id)
        db_record = Database::VideoOrm.first(video_id: video_id)
        rebuild_entity(db_record)
      end

      # Create a db_record from entity; if already exists, then return the one in db
      def self.create(entity)
        # fail 'Video already exists' if find(entity)

        Database::VideoOrm.unrestrict_primary_key
        db_project = Database::VideoOrm.find_or_create(entity.to_hash)

        rebuild_entity(db_project)
      end

      # Get an entity from db_record
      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Video.new(
          video_db_id: db_record.video_db_id,
          video_id: db_record.video_id,
          title: db_record.title
        )
      end
    end
  end
end
