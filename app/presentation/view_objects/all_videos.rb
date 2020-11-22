# frozen_string_literal: true

require_relative 'video'

module Views
  # View videos in database
  class AllVideos
    def initialize(videos)
      @videos = videos.map.with_index { |video, i| Video.new(video, i) }
    end

    def each
      @videos.each do |video|
        yield video
      end
    end

    def any?
      @videos.any?
    end
  end
end
