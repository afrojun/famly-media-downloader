# frozen_string_literal: true

require_relative 'queries/observations_by_ids'

module Famly
  module GraphQL
    module Queries
      def self.call(query, variables: {})
        response = Client.query(query, variables:)

        result = response&.data

        if !result
          pp response
          []
        else
          result
        end
      end

      def self.get_observations(observation_ids)
        result = call(
          ObservationsByIds::Query::ObservationsByIds,
          variables: { observationIds: observation_ids }
        )

        result&.child_development&.observations&.results
      end
    end
  end
end
