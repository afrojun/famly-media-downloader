# frozen_string_literal: true

require 'active_support/inflector'
require 'down'
require 'fileutils'

module Famly
  module MediaFile
    class Error < StandardError; end

    class Base
      DEST_DIR = 'output'

      attr_reader :file

      def initialize(file)
        @file = file
      end

      def id
        file['id']
      end

      def url
        file['url']
      end

      def name
        @name ||= begin
          date, id, extension = url.match(name_from_url_regex).captures
          param_date = ActiveSupport::Inflector.parameterize(date)
          param_id = ActiveSupport::Inflector.parameterize(id)

          "#{type}_#{param_date}_#{param_id}.#{extension}"
        rescue StandardError
          nil
        end
      end

      def type
        ActiveSupport::Inflector.demodulize(self.class.name)
      end

      def raw_data
        file
      end

      def destination
        File.join('.', DEST_DIR, name)
      end

      def download
        if db.where(name: name).present?
          puts "Skipping #{name} as it's already downloaded..."
          return
        end

        puts "Downloading #{name}..."
        tempfile = Down.download(url)
        FileUtils.mv(tempfile.path, destination)
        post_process

        db.insert(
          name: name,
          type: type,
          url: url,
          downloaded_at: Time.now.utc
        )
      end

      def db
        Famly::DB.from(:media_files)
      end

      def to_s
        JSON.dump(
          name: name,
          url: url
        )
      end

      protected

      def name_from_url_regex
        raise NotImplementedError
      end

      def post_process
        # Optional method to modify the media file after it is downloaded
      end
    end
  end
end
