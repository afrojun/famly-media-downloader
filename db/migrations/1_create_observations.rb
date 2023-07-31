# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table :observations do
      String :id, primary_key: true
      String :raw_data, text: true
      Time :created_at, index: true, null: false
      Time :processed_at
    end
  end
end
