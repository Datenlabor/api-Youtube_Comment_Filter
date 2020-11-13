# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:comments) do
      primary_key :comment_db_id
      String :comment_id, null: false

      foreign_key :video_db_id, :videos
      String :video_id, null: false

      String  :author, null: false
      String  :author_id, null: false
      String  :author_image, null: false
      String  :textDisplay, null: false

      Integer :likeCount, null: false
      Integer :totalReplyCount, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
