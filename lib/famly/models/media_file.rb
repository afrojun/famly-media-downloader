# frozen_string_literal: true

require_relative '../media_file/base'
require_relative '../media_file/image'
require_relative '../media_file/video'

module Famly
  module Models
    class MediaFile < Sequel::Model
      plugin :timestamps, update_on_create: true
      unrestrict_primary_key

      many_to_one :observation

      DEST_DIR = 'output'

      def before_save
        self.raw_data = JSON.dump(self[:raw_data]) if self[:raw_data].is_a?(Hash)

        super
      end

      def raw_data
        JSON.parse(self[:raw_data]) if self[:raw_data].present?
      end
    end
  end
end
