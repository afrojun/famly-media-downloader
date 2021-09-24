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
      # observation_ids = get_observation_ids
      observation_ids = [
        "e7c5dc18-bcff-4c07-a5bf-715fbc87fb38",
        "68e06722-0398-40b9-95f2-ec866104d574",
        # "b6717977-8ea5-4cc6-a229-c7b10b14d275",
        # "21b0f867-f415-4c98-bcd8-8a2b9440e14e",
        # "a3516828-8a7f-4a4c-ba38-1a77c920a790",
        # "e59bb851-1362-4b07-a952-b980f453a0ef",
        # "b04211e9-0d06-42ef-883f-df8519e91b7a",
      ]

      # pp observation_ids

      result = GraphQL::Client.query(
        GraphQL::Queries::ObservationsByIds::Query::ObservationsByIds,
        variables: { observationIds: observation_ids },
      )

      observations = result.data.child_development.observations.results

      observations.each do |observation|
        puts "\n\nObservation: #{observation.id}"
        pp "Images"
        if observation.images
          observation.images.each do |image|
            pp "#{image.secret.prefix}/#{image.secret.key}/2560x2560/#{image.secret.path}?expires=#{image.secret.expires}"
          end
        end

        pp "Video"
        if observation.video
          pp observation.video.videoUrl
        end

        pp "Files"
        if observation.files
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
