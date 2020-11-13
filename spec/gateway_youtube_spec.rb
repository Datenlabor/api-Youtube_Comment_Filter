# frozen_string_literal: true

require_relative 'spec_helper'
require_relative 'helpers/vcr_helper'

describe 'Test Youtube API library' do
  before do
    VcrHelper.configure_vcr_for_youtube
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Test Error API Token' do
    it 'Should raise exception on incorrect comment' do
      _(proc do
          GetComment::Youtube::VideoMapper.new(YT_TOKEN).extract('ffff')
        end).must_raise GetComment::Youtube::Api::Response::BadRequest
    end
    it 'Should raise exception when given wrong token' do
      _(proc do
          GetComment::Youtube::VideoMapper.new('WRONG_TOKEN').extract(VIDEO_ID)
        end).must_raise GetComment::Youtube::Api::Response::BadRequest
    end
  end

  describe 'Test the title' do
    before do
      @n_video = GetComment::Youtube::VideoMapper.new(YT_TOKEN).extract(VIDEO_ID)
      @title_keys = CORRECT_TITLE.keys
    end
    it 'Have same ID' do
      _(@n_video.video_id).must_equal CORRECT_TITLE['video_id']
    end
  end

  describe 'Test the fifth comment' do
    before do
      @video = GetComment::Youtube::CommentMapper.new(YT_TOKEN).extract(VIDEO_ID)
      @c_keys = CORRECT[5].keys
    end

    it 'Have same reply' do
      _(@video[5].textDisplay).must_equal CORRECT[5][@c_keys[0]]['text']
    end

    it 'Have same author' do
      _(@video[5].author).must_equal CORRECT[5][@c_keys[0]]['author']
    end

    it 'Have same like count' do
      _(@video[5].likeCount).must_equal CORRECT[5][@c_keys[0]]['likeCount']
    end

    it 'Have same total reply count' do
      _(@video[5].totalReplyCount).must_equal CORRECT[5][@c_keys[0]]['totalReplyCount']
    end
  end
end
