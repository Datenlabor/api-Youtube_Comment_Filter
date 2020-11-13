# frozen_string_literal: true

require 'roda'
require 'slim'

module GetComment
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', js: 'table_row.js', path: 'app/views/assets'
    plugin :halt

    route do |routing|
      routing.assets # load CSS

      # GET /
      routing.root do
        # videos = Repository::For.klass(Entity::Video).all
        view 'home'
        # view 'home', locals: { videos: videos }
      end

      routing.on 'history' do
        videos = Repository::For.klass(Entity::Video).all
        view 'history', locals: { videos: videos }
      end

      routing.on 'comments' do
        routing.is do
          # GET /comment/
          routing.post do
            yt_url = routing.params['youtube_url']
            routing.halt 400 unless yt_url.include? 'youtube.com'
            video_id = youtube_id(yt_url)
            # Get comments from Youtube
            yt_video = Youtube::VideoMapper.new(App.config.YT_TOKEN).extract(video_id)
            yt_comments = Youtube::CommentMapper.new(App.config.YT_TOKEN).extract(video_id)
            # Add video to database
            Repository::For.entity(yt_video).create(yt_video)
            Repository::For.klass(Entity::Comment).create_many(yt_comments)
            # Redirect users to comment page
            routing.redirect "comments/#{video_id}"
          end
        end

        routing.on String do |video_id|
          # GET /comment/{video_id}/
          routing.get do
            # Get the comments from database instead of Youtube
            yt_comments = Repository::For.klass(Entity::Comment).find_by_video_id(video_id)
            view 'comments', locals: { comments: yt_comments.map(&:to_hash) }
          end
        end
      end
    end

    # Helper function for extracting video_id from YouTube url
    def youtube_id(youtube_url)
      regex = %r{(?:youtube(?:-nocookie)?\.com/(?:[^/\n\s]+/\S+/|(?:v|e(?:mbed)?)/|\S*?[?&]v=)|youtu\.be/)([a-zA-Z0-9_-]{11})}
      match = regex.match(youtube_url)
      match[1] if match
    end
  end
end
