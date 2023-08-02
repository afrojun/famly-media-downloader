# frozen_string_literal: true

Sequel.migration do
  change do
    create_table :media_files do
      String :id, primary_key: true
      String :name
      String :type, null: false
      String :url
      String :raw_data, text: true
      foreign_key :observation_id, :observations, type: String
      Time :created_at, null: false
      Time :updated_at, null: false
      Time :downloaded_at
      Time :processed_at
    end
  end
end
