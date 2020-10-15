# frozen_string_literal: false

require_relative 'youtube_api'

module CodePraise
  # Model for comment
  class Comment
    def initialize(comment_data_raw)
      @raw = comment_data_raw
      @data = {}
    end

    def get_items(data)
      data['items']
    end

    def get_snippet(data)
      data['snippet']
    end

    def parsing(data)
      { 'text' => data['topLevelComment']['snippet']['textDisplay'],
        'author' => data['topLevelComment']['snippet']['authorDisplayName'],
        'likeCount' => data['topLevelComment']['snippet']['likeCount'],
        'totalReplyCount' => data['totalReplyCount'],
        'replies' => [] }
    end

    def extract
      @items = get_items(@raw)
      @items.each do |hash|
        snippet = get_snippet(hash)
        id = snippet['topLevelComment']['id']
        @data.store(id, parsing(snippet))
      end
      getting_yt_reply
      @data
    end

    def getting_yt_reply
      @data.each_key do |key|
        result = call_yt_api(key)
        write_in_reply(key, result)
      end
    end

    def write_in_reply(id, result)
      reply = get_items(result)
      reply.each do |hash|
        snippet = hash['snippet']
        @data[id]['replies'].append(snippet['textDisplay'])
      end
    end

    def call_yt_api(id)
      config = YAML.safe_load(File.read('../config/secrets.yml'))
      YoutubeApi.new(config['YT_KEY']).get_reply(id)
    end
  end
end
