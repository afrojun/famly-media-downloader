# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table :observations do
      String :id, primary_key: true
      String :variant
      String :raw_data, text: true
      Time :posted_at, index: true, null: false
      Time :created_at, null: false
      Time :updated_at, null: false
      Time :processed_at
    end
  end
end
