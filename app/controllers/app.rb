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
          # GET /project/
          routing.post do
            yt_url = routing.params['youtube_url']
            routing.halt 400 unless yt_url.include? 'youtube.com'
            video_id = youtube_id(yt_url)
            puts "==Debug== video_id for posting request is #{video_id}"
            routing.redirect "comments/#{video_id}"
          end
        end

        routing.on String do |video_id|
          # GET /project/owner/project
          routing.get do
            yt_comments = Youtube::CommentMapper.new(YT_TOKEN).extract(video_id)

            view 'comments', locals: { comments: yt_comments }
          end
        end
      end
    end

    def youtube_id(youtube_url)
      regex = %r{(?:youtube(?:-nocookie)?\.com/(?:[^/\n\s]+/\S+/|(?:v|e(?:mbed)?)/|\S*?[?&]v=)|youtu\.be/)([a-zA-Z0-9_-]{11})}
      match = regex.match(youtube_url)
      match[1] if match
    end
  end
end
