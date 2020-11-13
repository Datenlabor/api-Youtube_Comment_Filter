# frozen_string_literal: true

# Roda uses this to set and get our application's current environment.
ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'

require_relative '../init'

CORRECT = YAML.safe_load(File.read('spec/fixtures/results.yml'))
CORRECT_TITLE = YAML.safe_load(File.read('spec/fixtures/video_title.yml'))
VIDEO_ID = 'DA8nk83xumg'
YT_TOKEN = GetComment::App.config.YT_TOKEN

# CASSETTES_FOLDER = 'spec/spec/fixtures/cassettes'
# CASSETTE_FILE = 'youtube_api'
