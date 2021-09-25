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

      def name
        extension = file.secret.path.split(".").last
        url_parts = url.match(/archive\/(.*)\/images\/(.*)\/.*/)
        date, id = [url_parts[1], url_parts[2]]
        param_date = ActiveSupport::Inflector.parameterize(date)
        "#{type}_#{param_date}_#{id}.#{extension}"
      end
    end
  end
end
