# frozen_string_literal: true

require 'dry-validation'

module GetComment
  module Forms
    # Check the URL
    class NewVideo < Dry::Validation::Contract
      URL_REGEX = %r{(http[s]?)\:\/\/(www.)?youtube\.com\/watch\?v=*}.freeze

      params do
        required(:youtube_url).filled(:string)
      end

      rule(:youtube_url) do
        key.failure('Invalid') unless URL_REGEX.match?(value)
      end
    end
  end
end
