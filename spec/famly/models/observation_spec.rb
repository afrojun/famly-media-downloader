# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe Famly::Models::Observation do
  subject(:observation) { described_class.create(params) }

  let(:params) do
    {
      id: 'obs-1234',
      posted_at: '2023-07-30T12:36:27+00:00'
    }
  end
  let(:created_time) { '2023-07-31T10:26:27+00:00' }
  let(:raw_data) do
    {
      'id' => 'obs-1234',
      'createdBy' => { 'name' => { 'fullName' => 'Jane Doe' } },
      'files' => [],
      'images' => nil,
      'video' => nil,
      'variant' => 'REGULAR_OBSERVATION'
    }
  end

  around do |example|
    Timecop.freeze(created_time) { example.run }
  end

  context 'when creating a new observation' do
    it 'succeeds with valid params' do
      expect { observation }.to change(described_class, :count).by(1)
      expect(described_class.last.id).to eq('obs-1234')
    end

    it 'sets created_at and updated_at on new Observation records' do
      observation
      expect(observation.created_at.iso8601).to eq(created_time)
      expect(observation.updated_at.iso8601).to eq(created_time)
    end
  end

  context 'when updating an observation with raw_data' do
    before { observation }

    it 'saves raw_data as a JSON string and can be read back as a Hash' do
      observation.update(raw_data:)
      db_observation = described_class.last
      expect(db_observation[:raw_data]).to eq(JSON.dump(raw_data))
      expect(db_observation.raw_data).to eq(raw_data)
    end

    it 'changes the updated_at timestamp on updated Observation records' do
      Timecop.freeze(60)
      expect { observation.update(raw_data:) }.to(change(observation, :updated_at))
    end

    it 'does not change the created_at timestamp on updated Observation records' do
      Timecop.freeze(60)
      expect { observation.update(raw_data:) }.not_to(change(observation, :created_at))
    end
  end
end
