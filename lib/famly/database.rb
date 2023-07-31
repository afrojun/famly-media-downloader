# frozen_string_literal: true

require "sequel"

module Famly
  DB = Sequel.sqlite("./famly_media_downloader.db")

  module DataBase
    def self.setup
      Famly::DataBase::Migrate.new.call
    end
  end
end
