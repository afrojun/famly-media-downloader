# frozen_string_literal: true
ruby '3.2.2'

source 'https://rubygems.org'

gem 'down', '~> 5.0'
gem 'graphql-client'
gem 'mini_exiftool'
gem 'sequel'
gem 'sqlite3'

group :development, :test do
  gem 'dotenv'
  gem 'pry'
  gem 'rubocop', require: false
end

group :test do
  gem 'rspec'
  gem 'rubocop-rspec', require: false
  gem 'rubocop-sequel', require: false
  gem 'timecop'
end
