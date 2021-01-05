# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Setting up VCR
class VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'.freeze
  YOUTUBE_CASSETTE = 'youtube_api'.freeze
  YOUTUBE_TITLE_CASSETTE = 'youtube_title_api'.freeze

  def self.setup_vcr
    VCR.configure do |c|
      c.cassette_library_dir = CASSETTES_FOLDER
      c.hook_into :webmock
      c.ignore_localhost = true
      c.ignore_hosts 'sqs.us-east-1.amazonaws.com'
      c.ignore_hosts 'sqs.ap-northeast-1.amazonaws.com'
    end
  end

  def self.configure_vcr_for_youtube(recording: :new_episodes)
    VCR.configure do |c|
      c.filter_sensitive_data('<YOUTUBE_TOKEN>') { YT_TOKEN }
      c.filter_sensitive_data('<YOUTUBE_TOKEN_ESC>') { CGI.escape(YT_TOKEN) }
      c.filter_sensitive_data('<REDIS_URL>') { REDISCLOUD_URL }
      c.filter_sensitive_data('<REDIS_URL_ESC>') { CGI.escape(REDISCLOUD_URL) }
    end

    VCR.insert_cassette(
      YOUTUBE_CASSETTE,
      record: :new_episodes,
      match_requests_on: %i(method uri headers)
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
