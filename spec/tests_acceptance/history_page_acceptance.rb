# frozen_string_literal: true

require_relative '../helpers/acceptance_helper'
require_relative 'pages/home_page'
require_relative 'pages/comments_page'
require_relative 'pages/history_page'

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

  # TODO: history page acceptance test
end
