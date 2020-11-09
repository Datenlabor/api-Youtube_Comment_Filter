# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:comments) do
      String :id, primary_key: true
      String :video_id, null: false

      String  :author, null: false
      String  :textDisplay, null: false

      Integer :likeCount, null: false
      Integer :totalReplyCount, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
