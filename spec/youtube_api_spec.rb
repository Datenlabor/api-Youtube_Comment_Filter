# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'
require_relative '../lib/youtube_api'

CONFIG = YAML.safe_load(File.read('../config/secrets.yml'))
CORRECT = YAML.safe_load(File.read('fixtures/youtube_result.yml'))
VIDEO_ID = 'DA8nk83xumg'
YT_TOKEN = CONFIG['YT_KEY']

describe 'Test Youtube API library' do
  describe 'Test Error API Token' do
    # it 'Should raise exception on incorrect project' do
    #   _(proc do
    #       CodePraise::YoutubeApi.new(YT_TOKEN).get_comment('ffff')
    #     end).must_raise CodePraise::YoutubeApi::Errors::NotFound
    # end
    it 'Should raise exception when unauthorized' do
      _(proc do
          CodePraise::YoutubeApi.new('WRONG_TOKEN').get_comment(VIDEO_ID)
        end).must_raise CodePraise::YoutubeApi::Errors::Unauthorized
    end
  end
  describe 'Test informations' do
    before do
      @video = CodePraise::YoutubeApi.new(YT_TOKEN).get_comment(VIDEO_ID)
      @keys = @video.keys
      @c_keys = CORRECT[0].keys
    end

    it 'Have same reply' do
      _(@video[@key[0]]['text']).must_equal CORRECT[0][@c_keys[0]]['text']
    end

    it 'Have same author' do
      _(@video[@key[0]]['author']).must_equal CORRECT[0][@c_keys[0]]['author']
    end

    it 'Have same like count' do
      _(@video[@key[0]]['likeCount']).must_equal CORRECT[0][@c_keys[0]]['likeCount']
    end

    it 'Have same total reply count' do
      _(@video[@key[0]]['totalReplyCount']).must_equal CORRECT[0][@c_keys[0]]['totalReplyCount']
    end
  end
end
