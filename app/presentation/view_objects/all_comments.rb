# frozen_string_literal: true

require_relative 'comment'

module Views
  # View comments for a given video
  class AllComments
    attr_reader :video_id, :good, :bad
    def initialize(yt_comments, video_id)
      @comments = yt_comments.map.with_index { |comment, i| Comment.new(comment, i) }
      @video_id = video_id
      @good = 0
      @bad = 0
    end

    def each
      @comments.each do |comment|
        yield comment
      end
    end

    def any?
      @comments.any?
    end

    def classification
      @comments.each do |comment|
        comment.emotion? ? @good += 1 : @bad += 1
      end
    end
  end
end
