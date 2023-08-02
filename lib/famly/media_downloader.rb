# frozen_string_literal: true

require_relative 'models'

module Famly
  class MediaDownloader
    attr_reader :start_time, :end_time, :logger, :feed_api

    SLEEP_DURATION = 0.5

    def initialize(start_time: nil, end_time: nil)
      @start_time = start_time.presence || 1.year.ago.iso8601
      @end_time = oldest_observation_in_db.presence || end_time.presence || Time.now.utc.iso8601
      @feed_api = RestApi::Feed.new(start_time: Time.parse(@start_time), end_time: Time.parse(@end_time))
    end

    def call
      # Fetch all Observations using the REST API
      store_observations
      store_observation_raw_data
      create_media_files_from_observations
      download_media_files
      process_media_files
    end

    private

    def store_observations
      observation_items = feed_api.fetch_observation_items

      observation_items.each do |observation_item|
        next if Models::Observation.where(id: observation_item.observation_id).present?

        Models::Observation.create(
          id: observation_item.observation_id,
          posted_at: observation_item.created_date
        )
      end
    end

    def store_observation_raw_data
      # Iterate through all the Observations to extract media attachments
      Models::Observation.where(raw_data: nil).each_slice(90) do |observations|
        observations_by_id = observations.index_by(&:id)

        gql_observations = GraphQL::Queries.get_observations(observations_by_id.keys)

        gql_observations.each do |gql_observation|
          observation = observations_by_id[gql_observation.id]
          observation.update(raw_data: gql_observation.to_h.with_indifferent_access, variant: gql_observation.variant)
        end

        sleep SLEEP_DURATION
      end
    end

    def create_media_files_from_observations
      Models::Observation.where(processed_at: nil).each do |observation|
        Models::MediaFile.create_from_observation(observation)
        observation.update(processed_at: Time.now.utc)
      end
    end

    def download_media_files
      Models::MediaFile.where(downloaded_at: nil).each(&:download)
    end

    def process_media_files
      Models::MediaFile.where(processed_at: nil).where { downloaded_at !~ nil }.each(&:post_process)
    end

    def oldest_observation_in_db
      Famly::Models::Observation.min { posted_at }
    end
  end
end
