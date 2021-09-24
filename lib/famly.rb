# frozen_string_literal: true

require_relative "famly/rest_api"
require_relative "famly/graphql"
require_relative "famly/graphql/queries"

module Famly
  class MediaDownloader
    attr_reader :feed_api

    def initialize(feed_api: RestApi::Feed.new)
      @feed_api = feed_api
      @observation_ids = []
    end

    def fetch_data
      observation_ids = get_observation_ids

      result = GraphQL::Client.query(
        GraphQL::Queries::ObservationsByIds::Query::ObservationsByIds,
        variables: { observationIds: observation_ids },
      )

      observations = result.data.child_development.observations.results

      observations.each do |observation|
        puts "----------\n\nObservation: #{observation.id}"
        if observation.images && observation.images.any?
          puts "\nImages\n"
          observation.images.each do |image|
            pp "#{image.secret.prefix}/#{image.secret.key}/2560x2560/#{image.secret.path}?expires=#{image.secret.expires}"
          end
        end

        if observation.video
          puts "\nVideo\n"
          pp observation.video.videoUrl
        end

        if observation.files && observation.files.any?
          puts "\nFiles\n"
          observation.files.each do |file|
            pp file.url
          end
        end
      end
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
