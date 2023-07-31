# frozen_string_literal: true

require 'dotenv'

require_relative 'famly/database'
require_relative 'famly/rest_api'
require_relative 'famly/graphql'
require_relative 'famly/graphql/queries'
require_relative 'famly/media_downloader'

module Famly
  Dotenv.load('.env.local', '.env')
end
