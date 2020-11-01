# frozen_string_literal: false

module GetComment
  module Youtube
    # Model for commnet
    class CommentMapper
      def initialize(key, gateway_class = Youtube::Api)
        @yt_key = key
        @video_id = 0
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@yt_key)
      end

      def extract(video_id)
        # CommentMapper.extract_video_id(url)
        # We will get video_id directly from the controller of MVC
        @video_id = video_id
        raw_data = @gateway.get_comment(@video_id)
        # dataprocess = DataProcess.new(@yt_key, @video_id)
        data = DataProcess.new(@gateway, @video_id).processing(raw_data)
        build_entity(data)
      end

      # def extract(url)
      #   CommentMapper.extract_video_id(url)
      #   raw_data = @gateway.get_comment(@video_id)
      #   # dataprocess = DataProcess.new(@yt_key, @video_id)
      #   data = DataProcess.new(@gateway, @video_id).processing(raw_data)
      #   build_entity(data)
      # end

      def build_entity(data)
        DataMapper.new(data).build_entity
      end

      def self.extract_video_id(url)
        @video_id = url.sub(/&(.*)/, '')
        @video_id.sub!(/(.*)watch[?]v=/, '')
      end

      # For DataProcess
      class DataProcess
        def initialize(gateway, video)
          @items = []
          @data = {}
          # @yt_key = key
          @gateway = gateway
          @video_id = video
        end

        # For Getting the all pages comments
        class GetAllPage
          def initialize(data, gateway, video)
            @raw_data = data
            @pages_data = []
            # @yt_key_ = key
            @gateway = gateway
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
              @raw_data = @gateway.get_comment_pages(@video, @raw_data['nextPageToken'])
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
          def initialize(data, gateway)
            @data_ = data
            # @yt_key_ = key
            @gateway = gateway
          end

          def call_yt_api(id)
            @gateway.get_reply(id)
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
          @items = GetAllPage.new(data, @gateway, @video_id).getting_all_page
          @data = IterateItem.new(@items).iterative
          @data = GetYTReply.new(@data, @gateway).getting_yt_reply
          @data
        end
      end
      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
        end

        def build_entity
          Entity::Comment.new(
            id: nil,
            # yt_url: url,
            # video_id: video_id,
            data: @data
          )
        end
      end
    end
  end
end
