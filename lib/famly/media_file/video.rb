# frozen_string_literal: true

module Famly
  module MediaFile
    class Video < Base
      def url
        file.video_url
      end
    end
  end
end
