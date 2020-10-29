# frozen_string_literal: false

require_relative 'youtube_api'
module GetComment
  # Model for commnet
  class Comment
    def initialize(comment_data_raw, key, video)
      @raw = comment_data_raw
      @yt_key = key
      @video_id = video
    end

    def extract
      dataprocess = DataProcess.new(@yt_key, @video_id)
      dataprocess.processing(@raw)
    end

    # For DataProcess
    class DataProcess
      def initialize(key, video)
        @items = []
        @data = {}
        @yt_key = key
        @video_id = video
      end

      # For Getting the all pages comments
      class GetAllPage
        def initialize(data, key, video)
          @raw_data = data
          @pages_data = []
          @yt_key_ = key
          @video = video
        end

        def data_append
          rtn = GetDataItem.new(@raw_data).gets_items
          rtn.each do |hash|
            @pages_data.append(hash)
          end
        end

        def getting_all_page
          until data_append && !@raw_data.key?('nextPageToken')
            @raw_data = YoutubeApi.new(@yt_key_).get_comment_pages(@video, @raw_data['nextPageToken'])
          end
          @pages_data
        end
      end

      # For GetDataItem
      class GetDataItem
        def initialize(data)
          @data_item = data
        end

        def gets_items
          @data_item['items']
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
        @items = GetAllPage.new(data, @yt_key, @video_id).getting_all_page
        @data = IterateItem.new(@items).iterative
        @data = GetYTReply.new(@data, @yt_key).getting_yt_reply
      end
    end
  end
end
