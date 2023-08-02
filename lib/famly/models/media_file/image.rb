# frozen_string_literal: true

require 'mini_exiftool'

module Famly
  module MediaFile
    class Image < Base
      def url
        secret = file['secret']

        return if secret.blank?

        "#{secret['prefix']}" \
          "/#{secret['key']}" \
          '/2560x2560'\
          "/#{secret['path']}" \
          "?expires=#{secret['expires']}"
      end

      protected

      def name_from_url_regex
        %r{archive/(.*)/images/(.*/?.*)\.(.*)\?}
      end
    end
  end
end
