# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require_relative 'video_representer'

# Represents essential Repo information for API output
module GetComment
  module Representer
    # Representer object for project clone requests
    class FindCommentRequest < Roar::Decorator
      include Roar::JSON

      property :video, extend: Representer::Video, class: OpenStruct
      property :id
    end
  end
end
