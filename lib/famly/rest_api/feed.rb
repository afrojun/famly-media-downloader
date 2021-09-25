# frozen_string_literal: true

require "csv"
require "date"

module Famly
  module RestApi
    class Feed
      attr_reader :client, :db

      FEED_PATH = "/api/feed/feed/feed"
      SLEEP_DURATION = 1

      def initialize(client: Client.new, db: ObservationsDb.new)
        @client = client
        @db = db
      end

      def observation_ids
        observation_ids = []

        paginated_feed do |item|
          if item.observation_id.present?
            observation_ids << item.observation_id
            db.insert(item)
          end
        end

        observation_ids.compact
      end

      def paginated_feed
        last_item_time = processed_until

        loop do
          feed = client.get(FEED_PATH, olderThan: last_item_time)
          items = feed["feedItems"]

          # break if items.none?
          break if last_item_time < "2021-06-15T00:00:00+00:00"

          items.each do |item|
            yield Item.new(item)

            last_item_time = item["createdDate"] if item["createdDate"] < last_item_time
          end

          puts last_item_time
          sleep SLEEP_DURATION
        end
      end

      private

      def processed_until
        db.oldest_observation.fetch("created_at") { current_time }
      end

      def processed_from
        db.latest_observation.fetch("created_at") { current_time }
      end

      def current_time
        Time.now.utc.to_datetime.iso8601
      end
    end
  end
end
