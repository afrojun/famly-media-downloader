# frozen_string_literal: true

module Famly
  module RestApi
    class Item
      attr_reader :item

      def initialize(item)
        @item = item
      end

      def observation_id
        item.dig('embed', 'observationId')
      end

      def created_date
        item['createdDate']
      end

      def observation?
        observation_id.present?
      end
    end
  end
end
