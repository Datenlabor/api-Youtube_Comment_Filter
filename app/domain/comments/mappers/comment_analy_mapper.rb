# frozen_string_literal: true

module GetComment
  module Mapper
    #The class is for comment analysis mapper
    class CommentAnalyze
      def initialize(comment)
        @comment = comment
      end

      def build_entity
        Entity::Comment.new(
          comment: @comment
          polarity: polarity_value
        )
      end

      def polarity_value
        Entity::Polarity.new(        
          polarity: get_polarity(@comment)
        )
      end

      def get_polarity(comment)
        Value::Analysis.new(comment).polarity
      end
    end
  end
end
