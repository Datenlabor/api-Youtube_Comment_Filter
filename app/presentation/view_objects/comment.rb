# frozen_string_literal: true

module Views
  # Information of one comment
  class Comment
    def initialize(yt_comment)
      @comment = yt_comment
    end

    def author_image
      @comment.author_image
    end

    def author
      @comment.author
    end

    def text
      @comment.textDisplay
    end
  end
end
