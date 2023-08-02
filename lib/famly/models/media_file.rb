# frozen_string_literal: true

require_relative 'media_file/base'
require_relative 'media_file/file'
require_relative 'media_file/image'
require_relative 'media_file/video'

module Famly
  module Models
    class MediaFile < Sequel::Model
      plugin :timestamps, update_on_create: true
      unrestrict_primary_key

      many_to_one :observation

      DEST_DIR = 'output'

      def before_save
        self.raw_data = JSON.dump(self[:raw_data]) if self[:raw_data].is_a?(Hash)

        super
      end

      def raw_data
        JSON.parse(self[:raw_data]) if self[:raw_data].present?
      end

      def self.create_from_observation(observation)
        return if observation.raw_data.blank?

        files = []
        raw_data = observation.raw_data

        if raw_data['images'].present?
          raw_data['images'].each do |image|
            files << ::Famly::MediaFile::Image.new(image)
          end
        end

        files << ::Famly::MediaFile::Video.new(raw_data['video']) if raw_data['video']

        if raw_data['files'].present?
          puts "\n\n**********\nALERT: File found in observation #{observation.id}\n**********\n\n"
          raw_data['files'].each do |file|
            files << ::Famly::MediaFile::File.new(file)
          end
        end

        files.each do |file|
          create(
            id: file.id,
            name: file.name,
            type: file.type,
            url: file.url,
            raw_data: file.raw_data,
            observation_id: observation.id
          )
        end
      end
    end
  end
end
