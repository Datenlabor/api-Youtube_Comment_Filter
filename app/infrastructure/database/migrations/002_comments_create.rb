# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:comments) do
      primary_key :video_id

      String      :author, null: false
      String      :textDisplay, null: false

      Integer     :likeCount, null: false
      Integer     :totalReplyCount, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
