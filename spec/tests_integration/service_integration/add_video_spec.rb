# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'

describe 'AddVideo Service Integration Test' do
  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_youtube(recording: :none)
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store video' do
    #before do
    #  DatabaseHelper.wipe_database
    #end

    it 'HAPPY: should be able to find and save remote one videoid to database' do
      # GIVEN: a valid url request for an existing remote project:
      video = GetComment::Youtube::VideoMapper
              .new(YT_TOKEN).extract(VIDEO_ID)

      # WHEN: the service is called with the request form object
      video_made = GetComment::Service::AddVideo.new.call(video_id: VIDEO_ID)

      # THEN: the result should report success..
      _(video_made.success?).must_equal true

      # ..and provide a video entity with the right details
      rebuilt = video_made.value!.message

      _(rebuilt.video_id).must_equal(video.video_id)
      _(rebuilt.title).must_equal(video.title)
    end

    it 'HAPPY: should find and return existing project in database' do
      # GIVEN: a valid video id request for a video already in the database:
      db_project = GetComment::Service::AddVideo.new.call(
        video_id: VIDEO_ID
      ).value!.message

      # WHEN: the service is called with the request form object
      video_made = GetComment::Service::AddVideo.new.call(video_id: VIDEO_ID)

      # THEN: the result should report success..
      _(video_made.success?).must_equal true

      # ..and find the same video that was already in the database
      rebuilt = video_made.value!.message
      _(rebuilt.video_id).must_equal(db_project.video_id)

      # ..and provide a video entity with the right details
      _(rebuilt.video_id).must_equal(db_project.video_id)
      _(rebuilt.title).must_equal(db_project.title)
    end

    it 'SAD: should gracefully fail for non-existent video details' do
      # WHEN: the service is called with non-existent video details
      video_made = GetComment::Service::AddVideo.new.call(
        video_id: 'I_LOVE_IU'
      )

      # THEN: the service should report failure with an error message
      _(video_made.success?).must_equal false
      _(video_made.failure.message.downcase).must_include 'could not find'
    end
  end
end
