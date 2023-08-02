# frozen_string_literal: true

require 'sequel'

module Famly
  DB = if ENV.fetch('RACK_ENV', '') == 'test'
         Sequel.sqlite('./famly_media_downloader_test.db')
       else
         Sequel.sqlite('./famly_media_downloader_bak.db')
       end
end
