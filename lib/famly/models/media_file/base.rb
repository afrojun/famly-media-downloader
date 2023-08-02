# frozen_string_literal: true

require 'active_support/inflector'

module Famly
  module MediaFile
    class Error < StandardError; end

    class Base
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

      def to_s
        JSON.dump(
          name:,
          url:
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
