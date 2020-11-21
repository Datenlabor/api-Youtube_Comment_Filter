# frozen_string_literal: true

require_relative 'comment'

module Views
  # View for comments for a given video
  class AllComments
    attr_reader :video_id
    def initialize(yt_comments, video_id)
      @comments = yt_comments.map { |comment| Comment.new(comment) }
      @video_id = video_id
    end

    def each
      @comments.each do |comment|
        yield comment
      end
    end

    def any?
      @comments.any?
    end
  end
end
