# frozen_string_literal: true

require "active_support/inflector"
require "down"
require "fileutils"

module Famly
  module MediaFile
    class Base
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

      def download
        destination = File.join(".", "output", name)
        tempfile = Down.download(url)
        FileUtils.mv(tempfile.path, destination)
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
    end
  end
end
