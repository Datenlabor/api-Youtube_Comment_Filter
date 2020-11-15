# frozen_string_literal: true

module CodePraise
  module Entity
    #Entity for one comment
    class Comment

      attr_reader :comment

      def initialize(comment:)
        @comment = comment        
      end   
    end
  end
end
