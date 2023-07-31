# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe Famly::RestApi::Feed do
  subject { described_class.new(client:, db:).get_observations }

  let(:client) { instance_double(Famly::RestApi::Client) }
  let(:db) { Famly::DB.from(:observations) }
  let(:current_time) { '2023-07-31T10:26:27+00:00' }
  let(:feed_page1) do
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
  let(:feed_page2) do
    {
      'feedItems' => [
        {
          'embed' => { 'observationId' => 'obs3-id' },
          'createdDate' => '2023-07-28T12:36:27+00:00'
        },
        {
          'embed' => { 'observationId' => 'obs4-id' },
          'createdDate' => '2023-07-26T07:05:25+00:00'
        },
        {
          'embed' => {},
          'createdDate' => '2023-07-27T07:16:37+00:00'
        }
      ]
    }
  end

  around do |example|
    Timecop.freeze(current_time) { example.run }
  end

  before do
    stub_const("#{described_class}::SLEEP_DURATION", 0)
  end

  shared_examples_for 'extracts observations from feed' do |api_observations, db_observations|
    it 'returns the observation IDs fetched from the API' do
      expect(subject.map(&:observation_id)).to eq(api_observations)
    end

    it 'updates the DB with the observations' do
      subject

      expect(db.all.map { _1[:id] }).to eq(db_observations)
    end
  end

  context 'when the DB has no observations' do
    before do
      allow(client).to receive(:get).and_return(feed_page1, feed_page2, feed_page3)
    end

    context 'when the final page is empty' do
      let(:feed_page3) do
        {
          'feedItems' => []
        }
      end

      it_behaves_like(
        'extracts observations from feed',
        %w[obs1-id obs2-id obs3-id obs4-id],
        %w[obs1-id obs2-id obs3-id obs4-id]
      )
    end

    context 'when the final page is has data older than the cutoff date' do
      let(:feed_page3) do
        {
          'feedItems' => [
            {
              'embed' => {},
              'createdDate' => '2022-07-27T07:16:37+00:00'
            }
          ]
        }
      end

      it_behaves_like(
        'extracts observations from feed',
        %w[obs1-id obs2-id obs3-id obs4-id],
        %w[obs1-id obs2-id obs3-id obs4-id]
      )
    end
  end

  context 'when the DB already has observations' do
    let(:feed_page3) do
      {
        'feedItems' => []
      }
    end

    before do
      item = Famly::RestApi::Item.new(feed_page1['feedItems'].last)
      db.insert(id: item.observation_id, created_at: item.created_date)

      # allow(client).to receive(:get).and_return(feed_page3)
      allow(client).to receive(:get).with(
        kind_of(String), olderThan: feed_page1['feedItems'].last['createdDate']
      ).and_return(feed_page2)
      allow(client).to receive(:get).with(
        kind_of(String), olderThan: feed_page2['feedItems'].last['createdDate']
      ).and_return(feed_page3)
    end

    it_behaves_like 'extracts observations from feed', %w[obs3-id obs4-id], %w[obs2-id obs3-id obs4-id]
  end
end
