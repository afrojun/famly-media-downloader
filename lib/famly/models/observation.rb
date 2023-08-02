# frozen_string_literal: true

module Famly
  module Models
    class Observation < Sequel::Model
      plugin :timestamps, update_on_create: true
      unrestrict_primary_key

      one_to_many :media_file

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
