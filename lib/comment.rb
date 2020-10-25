# frozen_string_literal: false

require_relative 'youtube_api'
module CodePraise
  # Model for commnet
  class Comment
    def initialize(comment_data_raw, key)
      @raw = comment_data_raw
      @yt_key = key
    end

    def extract
      dataprocess = DataProcess.new(@yt_key)
      dataprocess.processing(@raw)
    end

    # For DataProcess
    class DataProcess
      def initialize(key)
        @items = []
        @data = {}
        @yt_key = key
      end

      # For GetDataItem
      class GetDataItem
        def initialize(data)
          @data_item = data['items']
        end

        def gets_items
          @data_item
        end
      end

      # For GetDataSnippet
      class GetDataSnippet
        def initialize(data)
          @data_snippet = data['snippet']
        end

        def gets_snippet
          @data_snippet
        end
      end

      # For DataParsing
      class DataParsing
        def initialize(data)
          @data_p = data
          @data_p_top_snp = data['topLevelComment']['snippet']
        end

        def parse_text
          @data_p_top_snp['textDisplay']
        end

        def parse_author
          @data_p_top_snp['authorDisplayName']
        end

        def parse_likecount
          @data_p_top_snp['likeCount']
        end

        def parse_totreply
          @data_p['totalReplyCount']
        end

        def parsing
          { 'text' => parse_text,
            'author' => parse_author,
            'likeCount' => parse_likecount,
            'totalReplyCount' => parse_totreply,
            'replies' => [] }
        end
      end

      # For IterateItem
      class IterateItem
        def initialize(items)
          @items_all = items
          @data_all = {}
        end

        def iterative
          @items_all.each do |hash|
            snippet = GetDataSnippet.new(hash).gets_snippet
            id = snippet['topLevelComment']['id']
            @data_all.store(id, DataParsing.new(snippet).parsing)
          end
          @data_all
        end
      end

      # For GetYTReply
      class GetYTReply
        def initialize(data, key)
          @data_ = data
          @yt_key_ = key
        end

        def call_yt_api(id)
          YoutubeApi.new(@yt_key_).get_reply(id)
        end

        def write_in_reply(id, result)
          reply = GetDataItem.new(result).gets_items
          reply.each do |hash|
            snippet = hash['snippet']
            @data_[id]['replies'].append(snippet['textDisplay'])
          end
        end

        def getting_yt_reply
          @data_.each_key do |key|
            result = call_yt_api(key)
            write_in_reply(key, result)
          end
        end
      end

      def processing(data)
        @items = GetDataItem.new(data).gets_items
        @data = IterateItem.new(@items).iterative
        @data = GetYTReply.new(@data, @yt_key).getting_yt_reply
      end
    end
  end
end
