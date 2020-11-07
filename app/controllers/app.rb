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
            # yt_video is an entity: {video_id => video_id, title => title}
            yt_video = Youtube::VideoMapper.new(App.config.YT_TOKEN).extract(video_id)
            puts "==DEBUG== yt_video entity: #{yt_video.inspect}"

            # DB=> Add video into database
            Repository::For.entity(yt_video).create(yt_video)

            # DB=> Get list of video entities from DB
            # db_videos = Repository::For.klass(Entity::Comment).all

            # Get a list of comment entities from API
            yt_comments = Youtube::CommentMapper.new(App.config.YT_TOKEN).extract(video_id)
            puts "==DEBUG== yt_comments[0] : #{yt_comments[0].inspect}"

            # DB=> Add comments into database
            Repository::For.klass(Entity::Comment).create_many(yt_comments)

            # DB=> Get list of comment entities from DB
            # db_comments = Repository::For.klass(Entity::Comment).find_by_video_id(video_id)

            # Transform the entities to hash and pass to view
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
