# frozen_string_literal: true

require "active_support/inflector"
require "down"
require "fileutils"

module Famly
  module MediaFile
    class Base
      DEST_DIR = "output"

      def initialize(file)
        @file = file
      end

      def url
        file.url
      end

      def name
        @name ||= begin
          date, id, extension = url.match(name_from_url_regex).captures
          param_date = ActiveSupport::Inflector.parameterize(date)
          param_id = ActiveSupport::Inflector.parameterize(id)

          "#{type}_#{param_date}_#{param_id}.#{extension}"
        rescue
          "Error_#{type}_#{ActiveSupport::Inflector.parameterize(url.split("?").first)}"
        end
      end

      def type
        ActiveSupport::Inflector.demodulize(self.class.name)
      end

      def destination
        File.join(".", DEST_DIR, name)
      end

      def download
        tempfile = Down.download(url)
        FileUtils.mv(tempfile.path, destination)
        post_process
      end

      def to_s
        {
          name: name,
          url: url,
        }
      end

      protected

      attr_reader :file

      def name_from_url_regex
        raise NotImplementedError
      end

      def post_process
        # Optional method to modify the media file after it is downloaded
      end
    end
  end
end
