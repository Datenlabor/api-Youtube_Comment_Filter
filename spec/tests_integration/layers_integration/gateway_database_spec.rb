# frozen_string_literal: false

require_relative 'spec_helper'
require_relative 'helpers/vcr_helper'
require_relative 'helpers/database_helper'

describe 'Integration Tests of Youtube API and Database' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_youtube
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store project' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'Should be able to save data and comments from Youtube to database' do
      comments = GetComment::Youtube::CommentMapper.new(YT_TOKEN).extract(VIDEO_ID)

      rebuilt = GetComment::Repository::For.klass(GetComment::Entity::Comment).create_many(comments)

      _(rebuilt[0].id).must_equal(comments[0].id)
      _(rebuilt[0].author).must_equal(comments[0].author)
      _(rebuilt[0].textDisplay).must_equal(comments[0].textDisplay)
      _(rebuilt[0].likeCount).must_equal(comments[0].likeCount)
      _(rebuilt[0].totalReplyCount).must_equal(comments[0].totalReplyCount)
    end

    it 'Should be able to save titles from Youtube to database' do
      videos = GetComment::Youtube::VideoMapper.new(YT_TOKEN).extract(VIDEO_ID)

      rebuilt = GetComment::Repository::For.klass(GetComment::Entity::Video).create(videos)
      _(rebuilt.video_id).must_equal(videos.video_id)
      _(rebuilt.title).must_equal(videos.title)
    end
  end
end
