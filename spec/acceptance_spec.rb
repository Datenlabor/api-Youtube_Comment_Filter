# frozen_string_literal: true

require_relative 'helpers/spec_helper'
require_relative 'helpers/database_helper'
require_relative 'helpers/vcr_helper'
require 'headless'
require 'watir'
require 'webdrivers/chromedriver'

describe 'Acceptance Tests' do
  DatabaseHelper.setup_database_cleaner

  before do
    DatabaseHelper.wipe_database
    # @headless = Headless.new
    @browser = Watir::Browser.new :chrome, headless: true
  end

  after do
    @browser.close
    # @headless.destroy
  end
  print 'yes'
  describe 'Homepage' do
    describe 'Visit Home page' do
      it '(HAPPY) should not see youtube_url if none created' do
        # GIVEN: user is on the home page without any youtube_url provided
        @browser.goto homepage

        # THEN: user should see basic headers, no history would show in this page
        _(@browser.title).must_equal 'YouTube Comment Filter'
        _(@browser.h1(css: '.text-center.title-1.text-danger').text).must_equal 'Youtube'
        _(@browser.h2(css: '.text-center.title-2.text-danger').text).must_equal 'Comment Filter'
        _(@browser.text_field(id: 'youtube_url_input').present?).must_equal true
        _(@browser.button(id: 'repo-form-submit').present?).must_equal true # get
        _(@browser.button(css: '.w-100.btn.btn-info').present?).must_equal true # history
      end

      #   it '(HAPPY) should not see youtube comment result because they did not request' do
      #     # GIVEN: a project exists in the database but user has not requested it
      #     yt_video = GetComment::Youtube::VideoMapper.new(YT_TOKEN).extract(VIDEO_ID)

      #     GetComment::Repository::For.entity(yt_video).create(yt_video)

      #     # WHEN: user goes to the homepage
      #     @browser.goto homepage

      #     # THEN: they should not see any projects
      #     #_(@browser.table(id: 'projects_table').exists?).must_equal false #??????
      #   end
    end

    describe 'Add Project' do
       it '(HAPPY) should be able to request a new youtube video' do
         # GIVEN: user is on the home page without any YouTube Comment
         @browser.goto homepage

         # WHEN: they add a project URL and submit
         good_url = "https://www.youtube.com/watch?v=#{VIDEO_ID}"
         @browser.text_field(id: 'youtube_url_input').set(good_url)
         @browser.button(id: 'repo-form-submit').click

         # THEN: they should find themselves on the project's page
         @browser.url.include? VIDEO_ID
       end

      it '(BAD) should not be able to add an invalid project URL' do
        # GIVEN: user is on the home page without any projects
        @browser.goto homepage

        # WHEN: they request a youtube url with an invalid URL
        bad_url = 'I_Love_IU'
        @browser.text_field(id: 'youtube_url_input').set(bad_url)
        @browser.button(id: 'repo-form-submit').click

        # THEN: they should see a warning message
        _(@browser.div(id: 'flash_bar_danger').present?).must_equal true
        _(@browser.div(id: 'flash_bar_danger').text.downcase).must_include 'invalid'
      end

      

      #   it '(SAD) should not be able to add valid but non-existent project URL' do
      #     # GIVEN: user is on the home page without any projects
      #     @browser.goto homepage

      #     # WHEN: they add a project URL that is valid but non-existent
      #     sad_url = "https://github.com/#{USERNAME}/foobar"
      #     @browser.text_field(id: 'url_input').set(sad_url)
      #     @browser.button(id: 'project_form_submit').click

      #     # THEN: they should see a warning message
      #     _(@browser.div(id: 'flash_bar_danger').present?).must_equal true
      #     _(@browser.div(id: 'flash_bar_danger').text.downcase).must_include 'could not find'
      #   end
    end

    # describe 'Delete Project' do
    #   it '(HAPPY) should be able to delete a requested project' do
    #     # GIVEN: user has requested and created a single project
    #     @browser.goto homepage
    #     good_url = "https://github.com/#{USERNAME}/#{PROJECT_NAME}"
    #     @browser.text_field(id: 'url_input').set(good_url)
    #     @browser.button(id: 'project_form_submit').click

    #     # WHEN: they revisit the homepage and delete the project
    #     @browser.goto homepage
    #     @browser.button(id: 'project[0].delete').click

    #     # THEN: they should not find any projects
    #     _(@browser.table(id: 'projects_table').exists?).must_equal false
    #   end
    # end
  end

   describe 'Project Page' do
     it '(HAPPY) should see youtube comments if the specific youtube history exists' do
       # GIVEN: a YT video exists
       yt_video = GetComment::Youtube::VideoMapper.new(YT_TOKEN).extract(VIDEO_ID)
       yt_comments = GetComment::Youtube::CommentMapper.new(YT_TOKEN).extract(VIDEO_ID)

       # Add video to database and get the entity with db_id
       video = GetComment::Repository::For.entity(yt_video).create(yt_video)
       # Add comments to database with the video_db_id they associate
       GetComment::Repository::For.klass(GetComment::Entity::Comment).create_many_of_one_video(yt_comments, video.video_db_id)

       # WHEN: user goes directly to the comments page
       @browser.goto "http://localhost:9000/comments/#{VIDEO_ID}"

       # THEN: they should see the comments details, check the comments are loaded correctly or not.
       
       _(@browser.div(css: '.d-flex.flex-column.justify-content-center.default-page').present?).must_equal true
       _(@browser.iframe(id: 'YouTubeVideoPlayer').present?).must_equal true
     end
   end
end
