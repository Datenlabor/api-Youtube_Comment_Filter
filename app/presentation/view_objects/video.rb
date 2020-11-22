# frozen_string_literal: true

module Views
  # Information of one video
  class Video
    attr_reader :index
    def initialize(video, index = nil)
      @video = video
      @index = index
    end

    def title
      @video.title
    end

    def id
      @video.video_id
    end

    def img
      "http://img.youtube.com/vi/#{id}/mqdefault.jpg"
    end
  end
end
