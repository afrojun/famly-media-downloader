# frozen_string_literal: true

require_relative '../../spec_helper'

RSpec.describe Famly::Models::MediaFile do
  let(:params) do
    {
      id: 'file-id',
      observation_id: 'obs-1234',
      name: 'test-file',
      type: 'Image',
      url: 'https://example.com'
    }
  end
  let(:observation) { ::Famly::Models::Observation.create(id: 'obs-1234', posted_at: Time.now) }

  before do
    observation
  end

  context 'when creating a new media file' do
    it 'succeeds with valid params' do
      expect { described_class.create(params) }.to change(described_class, :count).by(1)
      db_file = described_class.last
      expect(db_file.id).to eq('file-id')
      expect(db_file.observation.id).to eq('obs-1234')
    end
  end

  describe '.create_from_observation' do
    let(:raw_data) do
      {
        'id' => 'obs-1234',
        'createdBy' => { 'name' => { 'fullName' => 'Jane Doe' } },
        'files' => [],
        'images' => images,
        'video' => video,
        'variant' => 'REGULAR_OBSERVATION'
      }
    end
    let(:images) { nil }
    let(:video) { nil }

    before do
      observation.update(raw_data:)
    end

    context 'when no attached files are present' do
      it 'returns an empty array' do
        expect(described_class.create_from_observation(observation)).to eq([])
      end
    end

    context 'when observation contains raw_data with images' do
      let(:images) do
        [
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
          },
          {
            'height' => 1920,
            'width' => 2560,
            'id' => 'image-2',
            'secret' => {
              'crop' => nil,
              'expires' => '2023-08-01T19:00:00Z',
              'key' => 'anotherlongsecret',
              'path' => 'archive/2023/07/23/19/images/712/some-random-uuid-9876.jpg',
              'prefix' => 'https://img.famly.co/image'
            }
          }
        ]
      end

      it 'creates the Media Files' do
        expect { described_class.create_from_observation(observation) }.to change(described_class, :count).by(2)
        expect(described_class.find(id: 'image-1')).to be_present
        expect(described_class.find(id: 'image-2')).to be_present
      end
    end
  end
end
