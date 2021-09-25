# frozen_string_literal: true

module Famly
  module MediaFile
    class Video < Base
      def url
        file.video_url
      end

      protected

      def name_from_url_regex
        /amazonaws.com\/(.{4}\/.{2}\/.{2}\/.{2})\/.*\/(.*)\.(.*)\?/
      end
    end
  end
end
