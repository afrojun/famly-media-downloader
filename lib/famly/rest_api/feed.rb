# frozen_string_literal: true

require 'csv'
require 'date'

module Famly
  module RestApi
    class Feed
      attr_reader :client, :db

      FEED_PATH = '/api/feed/feed/feed'
      SLEEP_DURATION = 1
      CUTOFF_DATE = '2022-09-01'

      def initialize(client: Client.new, db: DB.from(:observations))
        @client = client
        @db = db
      end

      def get_observations
        paginated_feed
      end

      private

      def paginated_feed
        last_item_time = oldest_observation_in_db || current_time
        observation_items = []

        while last_item_time > Time.parse(CUTOFF_DATE)
          feed = client.get(FEED_PATH, olderThan: last_item_time.utc.to_datetime.iso8601)
          feed_items = feed['feedItems']

          break if feed_items.none?

          feed_items.each do |feed_item|
            item = Item.new(feed_item)

            if item.observation? && db.where(id: item.observation_id).blank?
              db.insert(id: item.observation_id, created_at: item.created_date)
              observation_items << item
            end
          end

          last_item_time = Time.parse(feed_items.last['createdDate'])
          puts "last_item_time: #{last_item_time}"

          sleep SLEEP_DURATION
        end

        observation_items
      end

      def oldest_observation_in_db
        db.select(:created_at).order(:created_at).limit(1).map { |o| o[:created_at] }.first
      end

      def current_time
        Time.now.utc
      end
    end
  end
end
