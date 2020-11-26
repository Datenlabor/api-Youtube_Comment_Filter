# frozen_string_literal: true

require_relative '../helpers/acceptance_helper'
require_relative 'pages/home_page'
require_relative 'pages/comments_page'

describe 'Comments Page Acceptance Tests' do
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

  describe 'Visit Comments Page' do
    it '(HAPPY) should see video & comments if video exists' do
      # GIVEN: user has requested a video
      visit HomePage do |page|
        good_url = "https://www.youtube.com/watch?v=#{VIDEO_ID}"
        page.add_new_video(good_url)
      end

      # WHEN: they visit the comments page
      visit(CommentsPage, using_params: { video_id: VIDEO_ID }) do |page|
        # THEN: they should see basic elements
        # _(page.video_player_element.present?).must_equal true
        _(page.happy_button_element.present?).must_equal true
        _(page.sad_button_element.present?).must_equal true
      end
    end

    # TODO: Implement error checking if video not requested
    # it '(HAPPY) should report an error if video not requested' do
    #   # GIVEN: user hasn't requested the video
    #   # WHEN: user directly visits the comments page
    #   visit(CommentsPage, using_params: { video_id: VIDEO_ID }) do |page|
    #     # THEN: they should see basic elements
    #   end
    # end
  end
end
