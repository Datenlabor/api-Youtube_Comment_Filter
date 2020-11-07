# frozen_string_literal: true

module GetComment
  module Repository
    # Repository for Video Entities
    class Videos
      # Get entities from all table records
      def self.all
        Database::VideoOrm.all.map { |db_project| rebuild_entity(db_project) }
      end

      # Methods to find the db_record that matches the video_id
      def self.find(entity)
        find_by_video_id(entity.video_id)
      end

      def self.find_by_video_id(video_id)
        db_record = Database::VideoOrm.first(video_id: video_id)
        rebuild_entity(db_record)
      end

      # Methods to create the db_record
      def self.create(entity)
        fail 'Video already exists' if find(entity)

        Database::VideoOrm.unrestrict_primary_key
        db_project = Database::VideoOrm.create(entity.to_hash)
        rebuild_entity(db_project)
      end

      # To get entity from db_record
      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Video.new(db_record.to_hash)
      end
    end
  end
end
