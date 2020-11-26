# frozen_string_literal: true

module Views
  # Information of one comment
  class Comment
    attr_reader :index

    def initialize(yt_comment, index = nil)
      @comment = yt_comment
      @index = index
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

    def emotion?
      @comment.polarity >= 0.5
    end
  end
end
