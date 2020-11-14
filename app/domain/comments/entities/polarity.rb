# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module GetComment
  module Entity
    # Polarity of a comment
    class Polarity < Dry::Struct
      include Dry.Types

      #attribute :comment,  Strict::String
      attribute :polarity, Strict::Float
    end
  end
end

