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
      @image_urls = []
      @video_urls = []
      @file_urls = []
    end

    def fetch_data
      obs_ids = get_observation_ids

      obs_ids.each_slice(10) do |ids|
        observations = get_observations(ids)
        extract_media_urls(observations) if observations

        sleep 0.5
      end

      pp @image_urls
      pp @video_urls
      pp @file_urls
    end

    private

    def get_observation_ids
      feed_api.paginated_feed do |item|
        @observation_ids.push(item.dig("embed", "observationId"))
      end

      @observation_ids.compact
    end

    def get_observations(observation_ids)
      result = GraphQL::Client.query(
        GraphQL::Queries::ObservationsByIds::Query::ObservationsByIds,
        variables: { observationIds: observation_ids },
      )

      observations = result&.data&.child_development&.observations&.results

      if !observations
        pp result
        []
      else
        observations
      end
    end

    def extract_media_urls(observations)
      observations.each do |observation|
        puts observation.id

        if observation.images && observation.images.any?
          observation.images.each do |image|
            @image_urls << "#{image.secret.prefix}/#{image.secret.key}/2560x2560/#{image.secret.path}?expires=#{image.secret.expires}"
          end
        end

        if observation.video
          @video_urls << observation.video.videoUrl
        end

        if observation.files && observation.files.any?
          observation.files.each do |file|
            @file_urls << file.url
          end
        end
      end
    end
  end
end
