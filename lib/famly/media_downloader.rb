# frozen_string_literal: true

require_relative "media_file/base"
require_relative "media_file/image"
require_relative "media_file/video"

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

    def db
      Famly::DB.from(:observations)
    end

    def fetch_data
      # Fetch all Observations using the REST API
      feed_api.get_observations
      obs_ids = db.select(:id).where(processed_at: nil).map { |o| o[:id] }

      # Iterate through all the Observations to extract media attachments
      obs_ids.each_slice(90) do |ids|
        gql_observations = get_observations(ids)
        build_files_from_observations(gql_observations) if gql_observations.present?

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

    def build_files_from_observations(gql_observations)
      gql_observations.each do |gql_observation|
        if gql_observation.images.present?
          gql_observation.images.each do |image|
            @files << MediaFile::Image.new(gql_observation.id, image)
          end
        end

        if gql_observation.video
          @files << MediaFile::Video.new(gql_observation.id, gql_observation.video)
        end

        if gql_observation.files.present?
          puts "\n\n**********\nALERT: File found in observation #{gql_observation.id}\n**********\n\n"
        end

        db.where(id: gql_observation.id).update(processed_at: Time.now.utc)
      end
    end
  end
end
