# frozen_string_literal: true

# Page object for home page
class HomePage
  include PageObject

  page_url GetComment::App.config.APP_HOST

  div(:warning_message, id: 'flash_bar_danger')
  div(:success_message, id: 'flash_bar_success')

  h1(:h1_heading, class: 'text-center')
  h2(:h2_heading, class: %w[text-center title-2 text-danger])
  text_field(:url_input, id: 'youtube_url_input')
  button(:url_submit_button, id: 'repo-form-submit')
  button(:history_button, id: 'show_history_button')

  def add_new_video(remote_url)
    self.url_input = remote_url
    url_submit_button
  end
end
