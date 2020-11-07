# frozen_string_literal: true

# Roda uses this to set and get our application's current environment.
ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../init'

CORRECT = YAML.safe_load(File.read('./fixtures/results.yml'))
VIDEO_ID = 'DA8nk83xumg'

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'youtube_api'
