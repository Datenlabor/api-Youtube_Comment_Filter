# frozen_string_literal: true

module GetComment
  module Repository
    # Repository for Video Entities
    class Videos
      def self.all
        Database::VideoOrm.all.map { |db_project| rebuild_entity(db_project) }
      end

      def self.find_full_name(owner_name, project_name)
        # SELECT * FROM `projects` LEFT JOIN `members`
        # ON (`members`.`id` = `projects`.`owner_id`)
        # WHERE ((`username` = 'owner_name') AND (`name` = 'project_name'))
        db_project = Database::VideoOrm
                     .left_join(:members, id: :owner_id)
                     .where(username: owner_name, name: project_name)
                     .first
        rebuild_entity(db_project)
      end

      def self.find(entity)
        find_origin_id(entity.origin_id)
      end

      def self.find_id(id)
        db_record = Database::VideoOrm.first(id: id)
        rebuild_entity(db_record)
      end

      def self.find_origin_id(origin_id)
        db_record = Database::VideoOrm.first(origin_id: origin_id)
        rebuild_entity(db_record)
      end

      def self.create(entity)
        fail 'Video already exists' if find(entity)

        db_project = PersistVideo.new(entity).call
        rebuild_entity(db_project)
      end

      private

      def self.rebuild_entity(db_record)
        return nil unless db_record

        Entity::Video.new(
          db_record.to_hash.merge(
            owner: Comments.rebuild_entity(db_record.owner),
            contributors: Comments.rebuild_many(db_record.contributors)
          )
        )
      end

      # Helper class to persist project and its members to database
      class PersistVideo
        def initialize(entity)
          @entity = entity
        end

        def create_project
          Database::VideoOrm.create(@entity.to_attr_hash)
        end

        def call
          owner = Comments.db_find_or_create(@entity.owner)

          create_project.tap do |db_project|
            db_project.update(owner: owner)

            @entity.contributors.each do |contributor|
              db_project.add_contributor(Comments.db_find_or_create(contributor))
            end
          end
        end
      end
    end
  end
end
