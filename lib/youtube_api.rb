# frozen_string_literal: false

require 'http'
require 'json'
require_relative 'comment'

module CodePraise
  # Library for Youtube Web API
  class YoutubeApi
    API_ROOT_URL = 'https://www.googleapis.com/youtube/v3'.freeze

    # Define some errors
    module Errors
      class BadRequest < StandardError; end
      class NotFound < StandardError; end
      class Unauthorized < StandardError; end
    end

    HTTP_ERROR = {
      400 => Errors::BadRequest,
      401 => Errors::Unauthorized,
      404 => Errors::NotFound
    }.freeze

    def initialize(key)
      @yt_key = key
    end

    def get_comment(videoid, part = 'snippet', order = 'relevance')
      url = "commentThreads?key=#{@yt_key}&videoId=#{videoid}"
      url += "&order=#{order}&part=#{part}"
      video_url = yt_api_path(url)
      comment_data_raw = call_yt_url(video_url).parse
      comment = Comment.new(comment_data_raw)
      comment.extract(@yt_key)
    end

    def get_reply(parent, part = 'snippet')
      url = "comments?key=#{@yt_key}&parentId=#{parent}&part=#{part}"
      reply_url = yt_api_path(url)
      call_yt_url(reply_url).parse
    end

    private

    def yt_api_path(path)
      "#{API_ROOT_URL}/#{path}"
    end

    def call_yt_url(url)
      result = HTTP.get(url)
      successful?(result) ? result : raise(HTTP_ERROR[result.code])
    end

    def successful?(result)
      HTTP_ERROR.keys.include?(result.code) ? false : true
    end
  end
end
