# frozen_string_literal: true

require "csv"
require "date"

module Famly
  module RestApi
    class Feed
      attr_reader :client, :db

      FEED_PATH = "/api/feed/feed/feed"
      SLEEP_DURATION = 1

      def initialize(client: Client.new, db: DB.from(:observations))
        @client = client
        @db = db
      end

      def get_observations
        paginated_feed do |item|
          if item.observation? && db.where(id: item.observation_id).blank?
            db.insert(id: item.observation_id, created_at: Time.parse(item.created_date))
          end
        end
      end

      private

      def paginated_feed
        loop do
          last_item_time = db.select(:created_at).order(:created_at).limit(1).map { |o| o[:created_at] }.first || current_time

          break if last_item_time < Time.parse('2022-08-10')

          feed = client.get(FEED_PATH, olderThan: last_item_time.utc.to_datetime.iso8601)
          items = feed["feedItems"]

          break if items.none?

          items.each do |item|
            yield Item.new(item)
          end

          puts "last_item_time: #{last_item_time}"
          sleep SLEEP_DURATION
        end
      end

      def current_time
        Time.now.utc
      end
    end
  end
end
