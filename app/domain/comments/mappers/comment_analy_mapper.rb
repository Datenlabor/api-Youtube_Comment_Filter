# frozen_string_literal: true

module GetComment
  module Mapper
    class CommentAnalyze
      def initialize

      end

      def build_entity
        Entity::Polarity.new(
          polarity: get_polarity
        )
      end
    end
  end
end
