# frozen_string_literal: true

require 'csv'
require 'date'

module Famly
  module RestApi
    class Feed
      attr_reader :client, :start_time, :end_time

      SLEEP_DURATION = 1

      def initialize(start_time: 1.week.ago, end_time: Time.now.utc, client: Client.new)
        @start_time = start_time
        @end_time = end_time
        @client = client
      end

      def fetch_observation_items
        last_item_time = end_time
        observations = []

        while last_item_time > start_time
          feed = client.get(olderThan: last_item_time.iso8601)
          feed_items = feed['feedItems']

          break if feed_items.blank?

          feed_items.each do |feed_item|
            item = Item.new(feed_item)

            observations << item if item.observation?
          end

          last_item_time = Time.parse(feed_items.last['createdDate'])
          puts "last_item_time: #{last_item_time}"

          sleep SLEEP_DURATION
        end

        observations
      end
    end
  end
end
