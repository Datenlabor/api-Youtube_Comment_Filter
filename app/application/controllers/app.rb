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
        view 'home'
      end

      routing.on 'history' do
        # Get videos from sessions
        puts "==DEBUG== Data in session is: #{session[:watching]}"

        result = Service::ListVideos.new.call(session[:watching])
        if result.failure?
          flash[:error] = result.failure
          video_list = []
        else
          videos = result.value!
          flash.now[:notice] = 'Let\'s Go Search!' if videos.none?
          video_list = Views::AllVideos.new(videos)
        end

        view 'history', locals: { videos: video_list }
      end

      routing.on 'comments' do
        routing.is do
          # GET /comment/
          routing.post do
            url_request = Forms::NewVideo.new.call(routing.params)
            video_made = Service::AddVideo.new.call(url_request)

            if video_made.failure?
              flash[:error] = video_made.failure
              routing.redirect '/'
            end

            video = video_made.value!
            session[:watching].insert(0, video.video_id).uniq!
            routing.redirect "comments/#{video.video_id}"
          end
        end

        routing.on String do |video_id|
          # GET /comment/{video_id}/
          routing.get do
            # Load comments
            yt_comments = Repository::For.klass(Entity::Comment)
                                         .find_by_video_id(video_id)
            all_comments = Views::AllComments.new(yt_comments, video_id)
            all_comments.classification
            view 'comments', locals: { comments: all_comments }
          end
        end
      end
    end
  end
end
