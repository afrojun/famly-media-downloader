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
      @files = []
    end

    def call
      fetch_data

      @files.each(&:download)
    end

    private

    def fetch_data
      obs_ids = feed_api.observation_ids
      # obs_ids = ["a72bcad3-6980-4863-880d-873d81010b0b"]

      obs_ids.each_slice(90) do |ids|
        observations = get_observations(ids)
        build_files_from_observations(observations) if observations.present?

        sleep 0.5
      end
    end

    def get_observations(observation_ids)
      result = GraphQL::Queries.call(
        :observations_by_ids,
        variables: { observationIds: observation_ids }
      )

      result&.child_development&.observations&.results
    end

    def build_files_from_observations(observations)
      observations.each do |observation|
        puts observation.id

        if observation.images.present?
          observation.images.each do |image|
            @files << MediaFile::Image.new(image)
          end
        end

        if observation.video
          @files << MediaFile::Video.new(observation.video)
        end

        if observation.files.present?
          puts "\n\n**********\nALERT: File found in observation #{observation.id}\n**********\n\n"
        end
      end
    end
  end
end
