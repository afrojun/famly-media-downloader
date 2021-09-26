# frozen_string_literal: true

require "mini_exiftool"

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

      def post_process
        date_string = url.match(name_from_url_regex)[1]
        date_parts = date_string.split("/").map { |s| Integer(s) }
        photo = MiniExiftool.new destination
        created_date = "#{date_parts[0]}/#{date_parts[1]}/#{date_parts[2]} #{date_parts[3]}:00:00"
        photo.date_time_original = created_date
        photo.create_date = created_date
        photo.modify_date = created_date
        photo.save
      end

      def name_from_url_regex
        /archive\/(.*)\/images\/(.*\/?.*)\.(.*)\?/
      end
    end
  end
end
