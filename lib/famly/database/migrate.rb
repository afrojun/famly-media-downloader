# frozen_string_literal: true

require_relative "1_create_observations"
require_relative "2_create_media_files"

module Famly
  module DataBase
    class Migrate
      def call
        CreateObservations.new.change
        CreateMediaFiles.new.change
      end
    end
  end
end
