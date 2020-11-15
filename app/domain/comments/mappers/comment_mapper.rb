# frozen_string_literal: true

module GetComment
  module Mapper
    class Comment
      def initialize; end

      def for_comment(_comment)
        Mapper::CommentAnaly.new(
          video_id
        ).build_entity
      end
    end
  end
end
