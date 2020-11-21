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
        # Get viewer's previously seen videos from session
        session[:watching] ||= []

        # videos = Repository::For.klass(Entity::Video).all
        view 'home'
        # view 'home', locals: { videos: videos }
      end

      routing.on 'history' do
        # Get videos from sessions
        puts "==DEBUG== Data in session is: #{session[:watching]}"
        videos = session[:watching].map do |video_id|
          Repository::For.klass(Entity::Video).find_by_video_id(video_id)
        end

        # videos = Repository::For.klass(Entity::Video).all
        view 'history', locals: { videos: videos }
      end

      routing.on 'comments' do
        routing.is do
          # GET /comment/
          routing.post do
            yt_url = routing.params['youtube_url']
            routing.halt 400 unless yt_url.include? 'youtube.com'
            video_id = youtube_id(yt_url)

            # Get video from Youtube
            yt_video = Youtube::VideoMapper.new(App.config.YT_TOKEN).extract(video_id)

            # Get comment from Youtube, extract the wanted fields and do sentiment analysis
            yt_comments = Youtube::CommentMapper.new(App.config.YT_TOKEN).extract(video_id)

            # Add video to database and get the entity with db_id
            video = Repository::For.entity(yt_video).create(yt_video)

            # Add comments to database with the video_db_id they associate
            Repository::For.klass(Entity::Comment).create_many_of_one_video(yt_comments, video.video_db_id)

            # Add search result to session cookie
            session[:watching].insert(0, video_id).uniq!

            # Redirect users to comment page
            routing.redirect "comments/#{video_id}"
          end
        end

        routing.on String do |video_id|
          # GET /comment/{video_id}/
          routing.get do
            # Get the comments from database instead of Youtube
            yt_comments = Repository::For.klass(Entity::Comment).find_by_video_id(video_id)
            view 'comments', locals: { comments: yt_comments, video_id: video_id }
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
