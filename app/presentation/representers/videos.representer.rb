# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'video_representer'

module GetComment
  module Representer
    # Represents list of projects for API output
    class VideosList < Roar::Decorator
      include Roar::JSON

      collection :videos, extend: Representer::Video,
                          class: Response::OpenStructWithLinks
    end
  end
end
