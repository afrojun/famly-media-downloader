# frozen_string_literal: true

require "sequel"

module Famly
  # Use an in-memory Sqlite DB for tests
  DB = ENV.fetch('RACK_ENV', '') == 'test' ? Sequel.sqlite : Sequel.sqlite("./famly_media_downloader_new.db")
end
