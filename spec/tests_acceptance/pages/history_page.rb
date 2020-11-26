# frozen_string_literal: true

# Page object for comments page
class CommentsPage
  include PageObject

  page_url "#{GetComment::App.config.APP_HOST}/comments/<%=params[:video_id]%>"

  div(:warning_message, id: 'flash_bar_danger')
  div(:success_message, id: 'flash_bar_success')

  indexed_property(
    :videos, [
      [:img, :video_image, { id: 'video_[%s]_img' }],
      [:h5, :title, { id: 'video_[%s]_author' }]
    ]
  )

  def first_video
    videos[0]
  end
end
