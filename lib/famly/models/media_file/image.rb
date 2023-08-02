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

      # Set the EXIF data in the image to ensure that it is sorted correctly when imported into
      # something like Google Photos.
      def post_process
        date_string = url.match(name_from_url_regex)[1]
        date_parts = date_string.split('/')
        photo = MiniExiftool.new destination
        created_date = "#{date_parts[0]}/#{date_parts[1]}/#{date_parts[2]} #{date_parts[3]}:00:00"
        photo.date_time_original = created_date
        photo.create_date = created_date
        photo.modify_date = created_date
        photo.save
      end

      def name_from_url_regex
        %r{archive/(.*)/images/(.*/?.*)\.(.*)\?}
      end
    end
  end
end
