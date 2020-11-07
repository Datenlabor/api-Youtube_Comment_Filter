# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:replies) do
      primary_key :id
      foreign_key :comments_id, :comments

      String      :reply, null: true

      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
