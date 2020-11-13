# frozen_string_literal: false

module GetComment
  module Youtube
    # Model for commnet
    class VideoMapper
      def initialize(yt_token, gateway_class = Youtube::Api)
        @video_id = 0
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(yt_token)
      end

      def extract(video_id)
        # Set video_id for mapper
        @video_id = video_id

        # get raw data from API
        raw_data = @gateway.get_title(@video_id)

        # Change to format {video_id => video_id, title => title}
        data = VideoDataProcess.new(@gateway, @video_id).processing(raw_data)

        # Build Entity
        EntityBuild.new(data).build_entity
      end

      # For Building the Entity class
      class EntityBuild
        def initialize(data)
          @data = data
        end

        def build_entity
          DataMapper.new(@data).build_entity
        end

        # Extracts entity specific elements from data structure
        class DataMapper
          def initialize(data)
            @data = data
          end

          def build_entity
            Entity::Video.new(
              video_db_id: nil,
              video_id: video_id,
              title: title
            )
          end

          def video_id
            @data['video_id']
          end

          def title
            @data['title']
          end
        end
      end

      # For VideoDataProcess
      class VideoDataProcess
        def initialize(gateway, video_id)
          @items = []
          @data = {}
          @gateway = gateway
          @video_id = video_id
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

        def processing(data)
          # Extract the data from data['items'], which contains a list of hashes
          @items = GetDataItem.new(data).gets_items

          # Get the snippet, which is a hash contains the title
          @data = GetDataSnippet.new(@items[0]).gets_snippet

          # Return the hash
          { 'video_id' => @video_id, 'title' => @data['title'] }
        end
      end
    end
  end
end
