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
    VcrHelper.configure_vcr_for_github
    DatabaseHelper.wipe_database
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
      GetComment::Service::AddVideo.new.call(
        video_id: VIDEO_ID
      )

      get "/api/v1/comments/#{VIDEO_ID}"
      _(last_response.status).must_equal 200
      appraisal = JSON.parse last_response.body
      _(appraisal.keys.sort).must_equal %w[folder project]
      _(appraisal['project']['name']).must_equal PROJECT_NAME
      _(appraisal['project']['owner']['username']).must_equal USERNAME
      _(appraisal['project']['contributors'].count).must_equal 3
      _(appraisal['folder']['path']).must_equal ''
      _(appraisal['folder']['subfolders'].count).must_equal 10
      _(appraisal['folder']['line_count']).must_equal 1450
      _(appraisal['folder']['base_files'].count).must_equal 2
    end

    it 'should be able to appraise a history' do
      GetComment::Service::AddProject.new.call(
        video_id: VIDEO_ID
      )

      get "/api/v1/projects/#{USERNAME}/#{PROJECT_NAME}/spec"
      _(last_response.status).must_equal 200
      appraisal = JSON.parse last_response.body
      _(appraisal.keys.sort).must_equal %w[folder project]
      _(appraisal['project']['name']).must_equal PROJECT_NAME
      _(appraisal['project']['owner']['username']).must_equal USERNAME
      _(appraisal['project']['contributors'].count).must_equal 3
      _(appraisal['folder']['path']).must_equal 'spec'
      _(appraisal['folder']['subfolders'].count).must_equal 1
      _(appraisal['folder']['line_count']).must_equal 151
      _(appraisal['folder']['base_files'].count).must_equal 3
    end

    it 'should be report error for an invalid videoid' do
      GetComment::Service::AddVideo.new.call(
        video_id: VIDEO_ID
      )

      get '/api/v1/comments/I_LOVE_IU'
      _(last_response.status).must_equal 404
      _(JSON.parse(last_response.body)['status']).must_include 'not'
    end
  end

  describe 'Add video comments' do
    it 'should be able to add a video comment' do
      post "/api/v1/comments/#{VIDEO_ID}"

      _(last_response.status).must_equal 201

      project = JSON.parse last_response.body
      _(project['name']).must_equal PROJECT_NAME
      _(project['owner']['username']).must_equal USERNAME

      proj = GetComment::Representer::Project.new(
        GetComment::Representer::OpenStructWithLinks.new
      ).from_json last_response.body
      _(proj.links['self'].href).must_include 'http'
    end

    it 'should report error for invalid videoid' do
      post '/api/v1/comments/I_LOVE_IU'

      _(last_response.status).must_equal 404

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'not'
    end
  end

  describe 'Get projects list' do
    it 'should successfully return project lists' do
      GetComment::Service::AddVideo.new.call(
        video_id: VIDEO_ID
      )

      list = [VIDEO_ID.to_s]
      encoded_list = GetComment::Request::EncodedProjectList.to_encoded(list)

      get "/api/v1/comments?list=#{encoded_list}"
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
      projects = response['projects']
      _(projects.count).must_equal 1
      project = projects.first
      _(project['name']).must_equal PROJECT_NAME
      _(project['owner']['username']).must_equal USERNAME
      _(project['contributors'].count).must_equal 3
    end

    it 'should return empty lists if none found' do
      list = ['I_LOVE_IU']
      encoded_list = GetComment::Request::EncodedProjectList.to_encoded(list)

      get "/api/v1/comments?list=#{encoded_list}"
      _(last_response.status).must_equal 200

      response = JSON.parse(last_response.body)
      projects = response['projects']
      _(projects).must_be_kind_of Array
      _(projects.count).must_equal 0
    end

    it 'should return error if not list provided' do
      get '/api/v1/comments'
      _(last_response.status).must_equal 400

      response = JSON.parse(last_response.body)
      _(response['message']).must_include 'list'
    end
  end
end
