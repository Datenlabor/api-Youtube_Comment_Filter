# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:comments_replies) do
      primary_key %i[comments_id replies_id]
      foreign_key :comments_id, :comments
      foreign_key :replies_id, :replies

      index %i[comments_id replies_id]
    end
  end
end
