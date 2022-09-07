# frozen_string_literal: true

module Famly
  module DataBase
    class CreateMediaFiles
      def change
        unless DB.table_exists?(:media_files)
          DB.create_table :media_files do
            String :name, primary_key: true
            String :type
            String :url
            String :observation_id
            Time :downloaded_at
          end
        end
      end
    end
  end
end
