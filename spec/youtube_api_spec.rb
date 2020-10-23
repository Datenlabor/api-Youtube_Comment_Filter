# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Test Youtube API library' do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock

    c.filter_sensitive_data('<YOUTUBE_TOKEN>') { YT_TOKEN }
    c.filter_sensitive_data('<YOUTUBE_TOKEN_ESC>') { CGI.escape(YT_TOKEN) }
  end

  before do
    VCR.insert_cassette CASSETTE_FILE,
                        record: :new_episodes,
                        match_requests_on: %i[method uri headers]
  end

  after do
    VCR.eject_cassette
  end

  describe 'Test Error API Token' do
    it 'Should raise exception on incorrect project' do
      _(proc do
          CodePraise::YoutubeApi.new(YT_TOKEN).get_comment('ffff')
        end).must_raise CodePraise::YoutubeApi::Errors::BadRequest
    end
    it 'Should raise exception when given wrong token' do
      _(proc do
          CodePraise::YoutubeApi.new('WRONG_TOKEN').get_comment(VIDEO_ID)
        end).must_raise CodePraise::YoutubeApi::Errors::BadRequest
    end
  end
  describe 'Test the first comment' do
    before do
      @video = CodePraise::YoutubeApi.new(YT_TOKEN).get_comment(VIDEO_ID)
      @keys = @video.keys
      @c_keys = CORRECT[0].keys
    end

    it 'Have same reply' do
      _(@video[@keys[0]]['text']).must_equal CORRECT[0][@c_keys[0]]['text']
    end

    it 'Have same author' do
      _(@video[@keys[0]]['author']).must_equal CORRECT[0][@c_keys[0]]['author']
    end

    it 'Have same like count' do
      _(@video[@keys[0]]['likeCount']).must_equal CORRECT[0][@c_keys[0]]['likeCount']
    end

    it 'Have same total reply count' do
      _(@video[@keys[0]]['totalReplyCount']).must_equal CORRECT[0][@c_keys[0]]['totalReplyCount']
    end
  end
end
