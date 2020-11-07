# frozen_string_literal: true

require 'roda'
require 'slim'

module GetComment
  # Web App
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :halt

    route do |routing|
      routing.assets # load CSS

      # GET /
      routing.root do
        view 'home'
      end

      routing.on 'comments' do
        routing.is do
          # GET /comment/
          routing.post do
            yt_url = routing.params['youtube_url']
            routing.halt 400 unless yt_url.include? 'youtube.com'
            video_id = youtube_id(yt_url)
            routing.redirect "comments/#{video_id}"
          end
        end

        routing.on String do |video_id|
          # GET /comment/owner/comment
          routing.get do
            # yt_video is an entity: {id => nil, video_id => video_id, title => title}
            yt_video = Youtube::VideoMapper.new(App.config.YT_TOKEN).extract(video_id)
            puts "==DEBUG== yt_video entity: #{yt_video.inspect}"

            # Add video into database, return the one if already exists
            Repository::For.entity(yt_video).create(yt_video)

            # yt_comments is an entity: {id => nil, video_id => video_id, data => comments}
            yt_comments = Youtube::CommentMapper.new(App.config.YT_TOKEN).extract(video_id)

            # pass yt_comments to view
            view 'comments', locals: { comments: yt_comments }
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
