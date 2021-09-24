# frozen_string_literal: true

require "date"
require "uri"
require "json"
require "net/http"

class Famly
  attr_reader :feed_api

  BASE_URL = "https://app.famly.co"

  def initialize(feed_api: FeedApi.new)
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

  class FeedApi
    attr_reader :before

    FEED_PATH = "/api/feed/feed/feed"
    SLEEP_DURATION = 1

    def initialize(before: current_time)
      @before = before
    end

    def paginated_feed
      last_item_time = before

      loop do
        feed = get(olderThan: last_item_time)
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

    def get(params)
      uri = URI("#{BASE_URL}#{FEED_PATH}")
      uri.query = URI.encode_www_form(params)

      req = Net::HTTP::Get.new(uri)
      req["x-famly-accesstoken"] = ENV.fetch("ACCESS_TOKEN")
      req["content-type"] = "application/json"

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      res.is_a?(Net::HTTPSuccess) ?  JSON.parse(res.body) : {}
    end
  end
end
