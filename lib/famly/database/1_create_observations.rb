# frozen_string_literal: true

module Famly
  module DataBase
    class CreateObservations
      def change
        unless DB.table_exists?(:observations)
          DB.create_table :observations do
            String :id, primary_key: true
            Time :created_at, index: true
            Time :processed_at
          end
        end
      end
    end
  end
end
