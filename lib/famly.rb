# frozen_string_literal: true

require_relative "famly/rest_api"
require_relative "famly/graphql"
require_relative "famly/graphql/queries"
require_relative "famly/media_file"

module Famly
  class MediaDownloader
    attr_reader :feed_api

    def initialize(feed_api: RestApi::Feed.new)
      @feed_api = feed_api
      @observation_ids = []
      @images = []
      @videos = []
      @files = []
    end

    def fetch_data
      # obs_ids = get_observation_ids
      obs_ids = ["e7c5dc18-bcff-4c07-a5bf-715fbc87fb38"]

      obs_ids.each_slice(10) do |ids|
        observations = get_observations(ids)
        extract_media_urls(observations) if observations

        sleep 0.5
      end

      pp @images
      pp @videos
      pp @files

      @images.each { |i| i.download }
    end

    private

    def get_observation_ids
      feed_api.paginated_feed do |item|
        observation_id = item.dig("embed", "observationId")
        true if observation_id.present?
        @observation_ids.push(observation_id)
      end

      @observation_ids.compact
    end

    def get_observations(observation_ids)
      result = GraphQL::Queries.call(
        :observations_by_ids,
        variables: { observationIds: observation_ids }
      )

      result&.child_development&.observations&.results
    end

    def extract_media_urls(observations)
      observations.each do |observation|
        puts observation.id

        if observation.images.present?
          observation.images.each do |image|
            @images << MediaFile::Image.new(image)
          end
        end

        if observation.video
          @videos << MediaFile::Video.new(observation.video)
        end

        if observation.files.present?
          observation.files.each do |file|
            @files << MediaFile::Base.new(file)
          end
        end
      end
    end
  end
end
