# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :media_files do
      String :name, primary_key: true
      String :type, null: false
      String :url, null: false
      foreign_key :observation_id, :observations
      Time :created_at, null: false
      Time :downloaded_at
    end
  end
end