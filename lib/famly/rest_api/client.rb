# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module Famly
  module RestApi
    class Client
      BASE_URL = "https://app.famly.co"

      def get(path, params)
        uri = URI("#{BASE_URL}#{path}")
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
end
