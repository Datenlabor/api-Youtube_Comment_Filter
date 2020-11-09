# frozen_string_literal: false

module GetComment
  module Youtube
    # Model for commnet
    class CommentMapper
      def initialize(yt_token, gateway_class = Youtube::Api)
        @video_id = 0
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(yt_token)
      end

      def extract(video_id)
        # CommentMapper.extract_video_id(url)
        # We will get video_id directly from the controller of MVC
        @video_id = video_id
        raw_data = @gateway.get_comment(@video_id)

        # Get a list of comments
        comments = DataProcess.new(@gateway).processing(raw_data)

        # Return a list of Comment entities
        comments.map do |comment|
          comment.store('video_id', @video_id)
          EntityBuild.new(comment).build_entity
        end
      end

      # For Building the Entity class
      class EntityBuild
        def initialize(data)
          @data = data
        end

        def build_entity
          DataMapper.new(@data).build_entity
        end
      end

      # For DataProcess
      class DataProcess
        def initialize(gateway)
          @items = []
          @data = {}
          # @yt_key = key
          @gateway = gateway
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

        # For DataParsing, parsing the comments
        class DataParsing
          def initialize(data)
            @data_p = data
            @data_p_top_snp = data['topLevelComment']['snippet']
          end

          def parse_id
            @data_p['topLevelComment']['id']
          end

          def parse_textDisplay
            @data_p_top_snp['textDisplay']
          end

          def parse_author
            @data_p_top_snp['authorDisplayName']
          end

          def parse_author_id
            @data_p_top_snp['authorChannelId']['value']
          end

          def parse_author_img
             @data_p_top_snp['authorProfileImageUrl']
          end

          def parse_likecount
            @data_p_top_snp['likeCount']
          end

          def parse_totreply
            @data_p['totalReplyCount']
          end

          def parsing
            {
              'id' => parse_id,
              'textDisplay' => parse_textDisplay,
              'author' => parse_author,
              'author_id' => parse_author_id,
              'author_image' => parse_author_img,
              'likeCount' => parse_likecount,
              'totalReplyCount' => parse_totreply,
              'replies' => []
            }
          end
        end

        # For IterateItem, now used for going through the list of comments
        # Generating a list of {id => id, video_id => ...} into @data_all
        class IterateItem
          def initialize(items)
            @items_all = items
            @data_all = []
          end

          def iterative
            @items_all.each do |hash|
              snippet = GetDataSnippet.new(hash).gets_snippet
              @data_all.append(DataParsing.new(snippet).parsing)
              # @data_all.store(id, DataParsing.new(snippet).parsing)
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

        # Process raw data of comment to list of hash
        def processing(data)
          # Extract the data from data['items'], which contains a list of hashes
          @items = GetDataItem.new(data).gets_items

          # Get a list of [{id => id, video_id => ...}, {...}] but yet including the replies
          @data = IterateItem.new(@items).iterative

          # Get the replies
          # @data = GetYTReply.new(@data, @gateway).getting_yt_reply

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
            id: @data['id'],
            video_id: @data['video_id'],
            author: @data['author'],
            textDisplay: @data['textDisplay'],
            likeCount: @data['likeCount'],
            totalReplyCount: @data['totalReplyCount']
          )
        end
      end
    end
  end
end
