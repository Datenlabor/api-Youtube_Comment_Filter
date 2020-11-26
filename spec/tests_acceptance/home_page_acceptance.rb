# frozen_string_literal: true

require_relative '../helpers/acceptance_helper'
require_relative 'pages/home_page'

describe 'Homepage Acceptance Tests' do
  include PageObject::PageFactory

  DatabaseHelper.setup_database_cleaner

  before do
    DatabaseHelper.wipe_database
    # Headless error? https://github.com/leonid-shevtsov/headless/issues/80
    # @headless = Headless.new
    @browser = Watir::Browser.new
  end

  after do
    @browser.close
    # @headless.destroy
  end

  describe 'Visit Home page' do
    it '(HAPPY) should see basic elements on the home page' do
      # GIVEN: Any user
      # WHEN: they visit the home page
      visit HomePage do |page|
        # THEN: they should see basic elements
        _(page.h1_heading).must_equal 'Youtube'
        _(page.h2_heading).must_equal 'Comment Filter'
        _(page.url_input_element.present?).must_equal true
        _(page.url_submit_button_element.present?).must_equal true
        puts "==DEBUG== history_button_element.present?: #{page.history_button_element.present?}"
        _(page.history_button_element.present?).must_equal true
      end
    end
  end

  describe 'Add Video' do
    it '(HAPPY) should be able to request a new youtube video' do
      # GIVEN: user is on the home page without any projects
      visit HomePage do |page|
        # WHEN: they add a project URL and submit
        good_url = "https://www.youtube.com/watch?v=#{VIDEO_ID}"
        page.add_new_video(good_url)

        # THEN: they should find themselves on the comments page
        # of the requested video
        @browser.url.include? VIDEO_ID
      end
    end

    it '(BAD) should not be able to add an invalid project URL' do
      # GIVEN: user is on the home page without any projects
      visit HomePage do |page|
        # WHEN: they request a youtube url with an invalid URL
        bad_url = 'I_Love_IU'
        page.add_new_video(bad_url)

        # THEN: they should see a warning message
        _(page.warning_message_element.present?).must_equal true
        _(page.warning_message.downcase).must_include 'invalid'
      end
    end
  end
end
