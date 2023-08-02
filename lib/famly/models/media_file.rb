# frozen_string_literal: true

require_relative 'media_file/base'
require_relative 'media_file/file'
require_relative 'media_file/image'
require_relative 'media_file/video'

require 'down'
require 'fileutils'

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
          raw_data['files'].each do |file|
            files << ::Famly::MediaFile::File.new(file)
          end
        end

        files.each do |file|
          find_or_create(id: file.id) do |f|
            f.name = file.name
            f.type = file.type
            f.url = file.url
            f.raw_data = file.raw_data
            f.observation_id = observation.id
          end
        end
      end

      def download
        puts "Downloading #{name}..."
        destination = File.join('.', DEST_DIR, name)
        tempfile = Down.download(url)
        FileUtils.mv(tempfile.path, destination)

        update(downloaded_at: Time.now.utc)
      end
    end
  end
end
