# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../lib/youtube_api'

CONFIG = YAML.safe_load(File.read('config/secrets.yml'))
CORRECT = YAML.safe_load(File.read('spec/fixtures/results.yml'))
VIDEO_ID = 'DA8nk83xumg'
YT_TOKEN = CONFIG['YT_KEY']

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE = 'youtube_api'
