# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

module GetComment
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, css: 'style.css', js: 'main.js',
                    path: 'app/presentation/assets'
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows DELETE and other HTTP verbs beyond GET/POST

    use Rack::MethodOverride # for other HTTP verbs (with plugin all_verbs)

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
        videos = Repository::For.klass(Entity::Video).find_videos(session[:watching])

        flash.now[:notice] = 'Let\'s Go Search!' if videos.none?

        video_list = Views::AllVideos.new(videos)

        view 'history', locals: { videos: video_list }
      end

      routing.on 'comments' do
        routing.is do
          # GET /comment/
          routing.post do
            yt_url = routing.params['youtube_url']
            unless yt_url.include? 'youtube.com'
              flash[:error] = 'Invalid URL'
              response.status = 400
              routing.redirect '/'
            end
            # routing.halt 400 unless yt_url.include? 'youtube.com'
            video_id = youtube_id(yt_url)
            # Get comments from database
            video = Repository::For.klass(Entity::Video).find_by_video_id(video_id)
            unless video
              # Get video from Youtube
              begin
                yt_video = Youtube::VideoMapper.new(App.config.YT_TOKEN)
                                               .extract(video_id)
              rescue StandardError
                flash[:error] = 'Could not find that video'
                routing.redirect '/'
              end

              # Get comment from Youtube, extract the wanted fields and do sentiment analysis
              yt_comments = Youtube::CommentMapper.new(App.config.YT_TOKEN)
                                                  .extract(video_id)

              # Add video to database and get the entity with db_id
              begin
                video = Repository::For.entity(yt_video).create(yt_video)
              rescue StandardError
                flash[:error] = 'Having trouble accessing the database'
                routing.redirect '/'
              end

              # Add comments to database with the video_db_id they associate
              begin
                Repository::For.klass(Entity::Comment)
                               .create_many_of_one_video(yt_comments,
                                                         video.video_db_id)
              rescue StandardError
                flash[:error] = 'Having trouble accessing the database'
                routing.redirect '/'
              end
            end

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
            begin
              video = Repository::For.klass(Entity::Video).find_by_video_id(video_id)
              if video.nil?
                flash[:error] = 'Video not found'
                routing.redirect '/'
              end
            rescue StandardError
              flash[:error] = 'Having trouble accessing the database'
              routing.redirect '/'
            end
            yt_comments = Repository::For.klass(Entity::Comment)
                                         .find_by_video_id(video_id)
            all_comments = Views::AllComments.new(yt_comments, video_id)
            all_comments.classification
            view 'comments', locals: { comments: all_comments }
            # view 'comments', locals: { comments: yt_comments, video_id: video_id }
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
