# frozen_string_literal: true

module GetComment
  module Repository
    # Finds the right repository for an entity object or class
    class For
      ENTITY_REPOSITORY = {
        Entity::Video => Videos,
        Entity::Comment => Comments
      }.freeze

      def self.klass(entity_klass)
        ENTITY_REPOSITORY[entity_klass]
      end

      def self.entity(entity_object)
        ENTITY_REPOSITORY[entity_object.class]
      end
    end
  end
end
