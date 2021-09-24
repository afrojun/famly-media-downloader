# frozen_string_literal: true

module Famly
  class MediaDownloader
    attr_reader :feed_api

    def initialize(feed_api: RestApi::Feed.new)
      @feed_api = feed_api
      @observation_ids = []
    end

    def fetch_data
      pp get_observation_ids
    end

    private

    def get_observation_ids
      feed_api.paginated_feed do |item|
        @observation_ids.push(item.dig("embed", "observationId"))
      end

      @observation_ids.compact
    end
  end
end
