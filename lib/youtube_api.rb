# frozen_string_literal: false

require 'http'
require 'json'
require_relative 'comment'

module CodePraise
  # Library for Youtube Web API
  class YoutubeApi
    API_ROOT_URL = 'https://www.googleapis.com/youtube/v3'.freeze

    def initialize(key)
      @yt_key = key
    end

    def get_comment(video_id, order = 'relevance', part = 'snippet')
      url = "commentThreads?key=#{@yt_key}&videoId=#{video_id}"
      url += "&order=#{order}&part=#{part}"
      video_comment = Request.new.get(yt_api_path(url)).parse
      comment = Comment.new(video_comment, @yt_key)
      comment.extract
    end

    def get_reply(parent, part = 'snippet')
      url = "comments?key=#{@yt_key}&parentId=#{parent}&part=#{part}"
      Request.new.get(yt_api_path(url)).parse
    end

    private

    def yt_api_path(path)
      "#{API_ROOT_URL}/#{path}"
    end

    # HTTP request
    class Request
      def get(url)
        http_response = HTTP.get(url)
        Response.new(http_response).tap do |response|
          raise(response.error) unless response.successful?
        end
      end
    end

    # HTTP response
    class Response < SimpleDelegator
      # BadRequest warning!
      BadRequest = Class.new(StandardError)

      # Unauthorized warning!
      Unauthorized = Class.new(StandardError)

      # NotFound warning!
      NotFound = Class.new(StandardError)

      HTTP_ERROR = {
        400 => BadRequest,
        401 => Unauthorized,
        404 => NotFound
      }.freeze

      def successful?
        HTTP_ERROR.keys.include?(code) ? false : true
      end

      def error
        HTTP_ERROR[code]
      end
    end
  end
end
