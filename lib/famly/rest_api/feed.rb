# frozen_string_literal: true

require "date"
require_relative "client"

module Famly
  module RestApi
    class Feed
      attr_reader :before, :client

      FEED_PATH = "/api/feed/feed/feed"
      SLEEP_DURATION = 1

      def initialize(before: current_time, client: Client.new)
        @before = before
        @client = client
      end

      def paginated_feed
        last_item_time = before

        loop do
          feed = client.get(FEED_PATH, olderThan: last_item_time)
          items = feed["feedItems"]

          # break if items.none?
          break if last_item_time < "2021-09-15T00:00:00+00:00"

          items.each do |item|
            yield item

            last_item_time = item["createdDate"] if item["createdDate"] < last_item_time
          end

          puts last_item_time
          sleep SLEEP_DURATION
        end
      end

      private

      def current_time
        Time.now.utc.to_datetime.iso8601
      end
    end
  end
end
