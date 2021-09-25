# frozen_string_literal: true

module Famly
  module RestApi
    class ObservationsDb
      DB_NAME = "processed_observations"

      def reset
        CSV.open(path, "wb") do |csv|
          csv << ["observation_id", "created_at", "processed_at"]
        end
      end

      def insert(item)
        CSV.open(path, "a") do |csv|
          csv << [item.observation_id, item.created_date, processed_at]
        end
      end

      def oldest_observation
        rows = CSV.read(path, headers: true)
        rows.sort { |a, b| a["created_at"] <=> b["created_at"] }.first
      end

      def latest_observation
        rows = CSV.read(path, headers: true)
        rows.sort { |a, b| a["created_at"] <=> b["created_at"] }.last
      end

      private

      def processed_at
        Time.now.utc.to_datetime.iso8601
      end

      def path
        File.join(".", "db", "#{DB_NAME}.csv")
      end
    end
  end
end
