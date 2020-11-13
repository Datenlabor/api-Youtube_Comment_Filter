# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:videos) do
      primary_key :video_db_id

      String :video_id, unique: true
      String :title, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
