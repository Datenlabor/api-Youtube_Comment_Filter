# frozen_string_literal: true

require_relative '../helpers/spec_helper'
require_relative '../helpers/vcr_helper'
require_relative '../helpers/database_helper'
require 'rack/test'

def app
  GetComment::App
end

describe 'Test API routes' do
  include Rack::Test::Methods

  VcrHelper.setup_vcr
  DatabaseHelper.setup_database_cleaner

  before do
    VcrHelper.configure_vcr_for_youtube
    #DatabaseHelper.wipe_database
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Root route' do
    it 'should successfully return root information' do
      get '/'
      _(last_response.status).must_equal 200

      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'ok'
      _(body['message']).must_include 'api/v1'
    end
  end

  describe 'Appraise a video comment' do
    it 'should be able to get a video comment' do
      GetComment::Service::AddVideo.new.call(video_id: VIDEO_ID)

      get "/api/v1/comments/#{VIDEO_ID}"

      _(last_response.status).must_equal 200

      appraisal = JSON.parse last_response.body

      _(appraisal['comments'][0]['video_id']).must_equal VIDEO_ID
      # _(appraisal['comments'].length()).must_be :<= 100
    end

    it 'should be report error for an invalid videoid' do
      GetComment::Service::AddVideo.new.call(
        video_id: VIDEO_ID
      )

      get '/api/v1/comments/I_LOVE_IU'
      _(last_response.status).must_equal 500

      _(JSON.parse(last_response.body)['message']).must_include 'trouble'
    end
  end

  describe 'Add video comments' do
    # it 'should be able to add a video comment' do
    #  #post "/api/v1/comments/#{VIDEO_ID}"

    #  _(last_response.status).must_equal 201

    #  project = JSON.parse last_response.body
    #  _(project['name']).must_equal PROJECT_NAME
    #  _(project['owner']['username']).must_equal USERNAME

    #  proj = GetComment::Representer::Project.new(
    #    GetComment::Representer::OpenStructWithLinks.new
    #  ).from_json last_response.body
    #  _(proj.links['self'].href).must_include 'http'
    # end

    it 'should report error for invalid videoid' do
      post '/api/v1/comments/I_LOVE_IU'

      _(last_response.status).must_equal 404

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'not find'
    end
  end
end
