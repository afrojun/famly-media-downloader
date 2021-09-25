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
        ActiveSupport::Inflector.parameterize(url)
      end

      def type
        ActiveSupport::Inflector.parameterize(self.class.name)
      end

      def download
        destination = File.join(".", "output", name)
        puts "downloading #{type} from #{url} and moving to #{destination}"
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
    end
  end
end
