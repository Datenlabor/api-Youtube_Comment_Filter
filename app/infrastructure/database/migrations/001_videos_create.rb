# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:videos) do
      String :video_id, primary_key: true
      String :title, null: false

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
