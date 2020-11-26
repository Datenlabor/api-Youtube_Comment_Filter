# frozen_string_literal: true

# Page object for comments page
class CommentsPage
  include PageObject

  page_url "#{GetComment::App.config.APP_HOST}/comments/<%=params[:video_id]%>"

  div(:warning_message, id: 'flash_bar_danger')
  div(:success_message, id: 'flash_bar_success')

  #   Couldn't find a way to detect iframe element
  #   in_frame(:video_player, id: 'YouTubeVideoPlayer')
  button(:happy_button, class: %w[emotion happy-button])
  button(:sad_button, class: %w[emotion sad-button])

  indexed_property(
    :comments, [
      [:img, :author_image, { id: 'comment_[%s]_img' }],
      [:h5, :author, { id: 'comment_[%s]_author' }],
      [:paragraph, :text, { id: 'comment_[%s]_text' }]
    ]
  )
end
