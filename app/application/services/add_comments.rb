# frozen_string_literal: true

require 'dry/transaction'

module GetComment
  module Service
    # Add comment in database
    class AddComment
      include Dry::Transaction
      step :find_comment
      step :store_comment

      private

      def find_comment(input)
        if get_video(input)
          input[:local_comment] = comment
        else
          input[:remote_comment] = comment_from_youtube(input)
        end
        Success(input)
      rescue StandardError => error
        Failure(error.to_s)
      end

      def store_comment(input)
        comments =
          if (new_comments = input[:remote_comment])
            Repository::For.klass(Entity::Comment)
                           .create_many_of_one_video(new_comments, get_video(input).video_db_id)
          else
            input[:local_comment]
          end
        Success(comments)
      rescue StandardError => error
        puts error.backtrace.join("\n")
        Failure('Having trouble accessing the database')
      end

      # following are support methods that other services could use
      def comment_from_youtube(input)
        Youtube::CommentMapper.new(App.config.YT_TOKEN).extract(input)
      rescue StandardError
        raise 'Could not find comments on Youtube'
      end

      def comment_in_database(input)
        Repository::For.klass(Entity::Comment).find_by_video_id(input)
      end

      def get_video(input)
        Repository::For.klass(Entity::Video).find_by_video_id(input)
      end
    end
  end
end
