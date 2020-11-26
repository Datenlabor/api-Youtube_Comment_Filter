# frozen_string_literal: true

ENV['RACK_ENV'] = 'app_test'

require 'headless'
require 'watir'
require 'page-object'
require 'webdrivers/chromedriver'

require_relative 'spec_helper'
require_relative 'database_helper'
