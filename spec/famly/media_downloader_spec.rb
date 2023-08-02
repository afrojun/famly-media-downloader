# frozen_string_literal: true

require_relative '../spec_helper'
require 'ostruct'

RSpec.describe Famly::MediaDownloader do
  subject(:media_downloader) { described_class.new(start_time:, end_time:).call }

  let(:start_time) { nil }
  let(:end_time) { nil }
  let(:feed_client) { instance_double(Famly::RestApi::Client) }
  let(:current_time) { '2023-07-31T10:26:27+00:00' }
  let(:feed_items) do
    {
      'feedItems' => [
        {
          'embed' => { 'observationId' => 'obs1-id' },
          'createdDate' => '2023-07-30T12:36:27+00:00'
        },
        {
          'embed' => {},
          'createdDate' => '2023-07-29T07:16:37+00:00'
        },
        {
          'embed' => { 'observationId' => 'obs2-id' },
          'createdDate' => '2023-07-29T07:05:25+00:00'
        }
      ]
    }
  end
  let(:empty_feed) { { 'feedItems' => [] } }
  let(:graphql_response) do
    OpenStruct.new(
      data: OpenStruct.new(
        child_development: OpenStruct.new(
          observations: OpenStruct.new(
            results: observations
          )
        )
      )
    )
  end
  let(:observations) do
    [
      OpenStruct.new(
        {
          'id' => 'obs1-id',
          'createdBy' => { 'name' => { 'fullName' => 'Jane Doe' } },
          'files' => [],
          'images' => [
            {
              'height' => 1920,
              'width' => 2560,
              'id' => 'image-1',
              'secret' => {
                'crop' => nil,
                'expires' => '2023-08-01T19:00:00Z',
                'key' => 'verylongsecret',
                'path' => 'archive/2023/07/27/12/images/687/some-random-uuid-1234.jpg',
                'prefix' => 'https://img.famly.co/image'
              }
            }
          ],
          'video' => nil,
          'variant' => 'REGULAR_OBSERVATION'
        }
      ),
      OpenStruct.new(
        {
          'id' => 'obs2-id',
          'createdBy' => { 'name' => { 'fullName' => 'John Doe' } },
          'files' => [],
          'images' => [
            {
              'height' => 1920,
              'width' => 2560,
              'id' => 'image-2',
              'secret' => {
                'crop' => nil,
                'expires' => '2023-08-01T19:00:00Z',
                'key' => 'e79d7ea710f391535b8082fbdb28c283e06cde2aaf17ea0d2a80c49d9230eabe',
                'path' => 'archive/2023/07/27/12/images/712/d7aeb637-9737-42ab-afe2-e5aaceda5603.jpg',
                'prefix' => 'https://img.famly.co/image'
              }
            }
          ],
          'video' => nil,
          'variant' => 'REGULAR_OBSERVATION'
        }
      )
    ]
  end

  around do |example|
    Timecop.freeze(current_time) { example.run }
  end

  before do
    stub_const('Famly::RestApi::Feed::SLEEP_DURATION', 0)
    stub_const("#{described_class}::SLEEP_DURATION", 0)

    allow(Famly::RestApi::Client).to receive(:new).and_return(feed_client)
    allow(feed_client).to receive(:get).and_return(empty_feed)

    allow(Famly::GraphQL::Client)
      .to receive(:query).with(
        Famly::GraphQL::Queries::ObservationsByIds::Query::ObservationsByIds,
        variables: { observationIds: %w[obs1-id obs2-id] }
      ).and_return(graphql_response)

    allow(Down).to receive(:download).twice.and_return(Tempfile.new('media_file'))
    allow(FileUtils).to receive(:mv).twice
  end

  context 'when the DB has no observations' do
    before do
      allow(feed_client).to receive(:get).with(olderThan: Time.now.utc.iso8601).and_return(feed_items)
    end

    it 'updates the DB with the observations' do
      media_downloader

      expect(Famly::Models::Observation.all.map { _1[:id] }).to eq(%w[obs1-id obs2-id])
      expect(Famly::Models::MediaFile.all.map { _1[:id] }).to eq(%w[image-1 image-2])
    end

    it 'downloads the media files' do
      media_downloader

      expect(Famly::Models::MediaFile.all.map { _1[:downloaded_at] }.compact.size).to eq(2)
    end
  end

  context 'when the DB already has observations' do
    before do
      item = Famly::RestApi::Item.new(feed_items['feedItems'].shift)
      Famly::Models::Observation.create(id: item.observation_id, posted_at: item.created_date)

      allow(feed_client).to receive(:get).with(olderThan: item.created_date).and_return(feed_items)
    end

    it 'updates the DB with the observations' do
      media_downloader

      expect(Famly::Models::Observation.all.map { _1[:id] }).to eq(%w[obs1-id obs2-id])
      expect(Famly::Models::MediaFile.all.map { _1[:id] }).to eq(%w[image-1 image-2])
    end
  end
end
