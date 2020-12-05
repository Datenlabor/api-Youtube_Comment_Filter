# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'comment_representer'

module GetComment
  module Representer
    # Represents list of projects for API output
    class CommentsList < Roar::Decorator
      include Roar::JSON

      collection :comments, extend: Representer::Comment,
                            class: OpenStruct
    end
  end
end
