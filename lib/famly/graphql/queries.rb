# frozen_string_literal: true

require_relative 'queries/observations_by_ids'

module Famly
  module GraphQL
    module Queries
      QUERY = {
        observations_by_ids: ObservationsByIds::Query::ObservationsByIds
      }

      def self.call(query, variables: {})
        response = Client.query(QUERY[query], variables: variables)

        result = response&.data

        if !result
          pp response
          []
        else
          result
        end
      end
    end
  end
end
