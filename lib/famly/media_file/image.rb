# frozen_string_literal: true

module Famly
  module MediaFile
    class Image < Base
      def url
        "#{file.secret.prefix}" \
          "/#{file.secret.key}" \
          "/2560x2560"\
          "/#{file.secret.path}" \
          "?expires=#{file.secret.expires}"
      end

      protected

      def name_from_url_regex
        /archive\/(.*)\/images\/(.*\/?.*)\.(.*)\?/
      end
    end
  end
end
