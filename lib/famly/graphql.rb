# frozen_string_literal: true

require "graphql/client"
require "graphql/client/http"

module Famly
  module GraphQL
    # Configure GraphQL endpoint using the basic HTTP network adapter.
    HTTP = ::GraphQL::Client::HTTP.new("https://app.famly.co/graphql") do
      def headers(_context)
        {
          "x-famly-accesstoken": ENV.fetch("FAMLY_ACCESS_TOKEN")
        }
      end
    end

    Schema = ::GraphQL::Client.load_schema("config/schema.json")

    Client = ::GraphQL::Client.new(schema: Schema, execute: HTTP)
  end
end
