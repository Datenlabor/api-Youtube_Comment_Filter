# frozen_string_literal: false

require 'http'
require 'json'
# require_relative 'comment'

module GetComment
  module Youtube
    # Library for Youtube Web API
    class Api
      API_ROOT_URL = 'https://www.googleapis.com/youtube/v3'.freeze

      def initialize(key)
        @yt_key = key
      end

      def get_comment(video_id)
        url = "commentThreads?key=#{@yt_key}&videoId=#{video_id}"
        url += '&order=time&part=snippet&maxResults=25'
        Request.new.get(yt_api_path(url)).parse
      end

      def get_reply(parent, part = 'snippet')
        url = "comments?key=#{@yt_key}&parentId=#{parent}&part=#{part}"
        Request.new.get(yt_api_path(url)).parse
      end

      def get_title(video_id, part = 'snippet')
        url = "videos?key=#{@yt_key}&id=#{video_id}&part=#{part}"
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
end
