# frozen_string_literal: true

require 'roda'
require 'slim'
require 'slim/include'

module GetComment
  # Web App
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows DELETE and other HTTP verbs beyond GET/POST

    use Rack::MethodOverride # for other HTTP verbs (with plugin all_verbs)

    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "YouTube Comment Filter API v1 at /api/v1/ in #{App.environment} mode"

        result_response = Representer::HttpResponse.new(
          Response::ApiResult.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do
        routing.on 'history' do
          routing.get do
            list_req = Request::EncodedVideoList.new(routing.params)
            result = Service::ListVideos.new.call(list_request: list_req)
            if result.failure?
              failed = Representer::HttpResponse.new(result.failure)
              routing.halt failed.http_status_code, failed.to_json
            end
            http_response = Representer::HttpResponse.new(result.value!)
            response.status = http_response.http_status_code
            Representer::VideosList.new(result.value!.message).to_json
          end
        end
        routing.on 'comments' do
          routing.on String do |video_id|
            # GET /comments/{video_id}
            routing.get do
              path_request = Request::VideoPath.new(video_id, request)
              result = Service::Comment.new.call(requested: path_request)

              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code

              Representer::CommentsList.new(
                result.value!.message
              ).to_json
            end
            # POST /comments/
            routing.post do
              result = Service::AddVideo.new.call(video_id: video_id)
              if result.failure?
                failed = Representer::HttpResponse.new(result.failure)
                routing.halt failed.http_status_code, failed.to_json
              end

              http_response = Representer::HttpResponse.new(result.value!)
              response.status = http_response.http_status_code
              Representer::Video.new(result.value!.message).to_json
            end
          end
        end
      end
    end
  end
end
