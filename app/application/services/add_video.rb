# frozen_string_literal: true

require 'dry/transaction'

module GetComment
  module Service
    # Add video in database
    class AddVideo
      include Dry::Transaction
      step :parse_url
      step :find_video
      step :store_video

      private

      # Helper function for extracting video_id from YouTube url
      def parse_url(input)
        if input.success?
          video_id = youtube_id(input[:youtube_url])
          Success(video_id: video_id)
        else
          Failure("URL #{input.errors.messages.first}")
        end
      end

      def find_video(input)
        if (video = video_in_database(input))
          input[:local_video] = video
        else
          input[:remote_video] = video_from_youtube(input)
          input[:remote_comment] = comment_from_youtube(input)
        end
        Success(input)
      rescue StandardError => error
        Failure(error.to_s)
      end

      def store_video(input)
        video =
          if input[:remote_video]
            store_video_comment(input)
          else
            input[:local_video]
          end
        Success(video)
      rescue StandardError => error
        puts error.backtrace.join("\n")
        Failure('Having trouble accessing the database')
      end

      # following are support methods that other services could use

      def youtube_id(youtube_url)
        regex = %r{(?:youtube(?:-nocookie)?\.com/(?:[^/\n\s]+/\S+/|(?:v|e(?:mbed)?)/|\S*?[?&]v=)|youtu\.be/)([a-zA-Z0-9_-]{11})}
        match = regex.match(youtube_url)
        match[1] if match
      end

      def video_from_youtube(input)
        Youtube::VideoMapper.new(App.config.YT_TOKEN)
                            .extract(input[:video_id])
      rescue StandardError
        raise 'Could not find that video on Youtube'
      end

      def video_in_database(input)
        Repository::For.klass(Entity::Video).find_by_video_id(input[:video_id])
      end

      def comment_from_youtube(input)
        Youtube::CommentMapper.new(App.config.YT_TOKEN).extract(input[:video_id])
      rescue StandardError
        raise 'Could not find comments on Youtube'
      end

      def store_video_comment(input)
        video = Repository::For.entity(input[:remote_video]).create(input[:remote_video])
        Repository::For.klass(Entity::Comment)
                       .create_many_of_one_video(input[:remote_comment], video.video_db_id)
        video
      end
    end
  end
end