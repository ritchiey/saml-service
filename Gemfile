# frozen_string_literal: true
source 'https://rubygems.org'

# Core
gem 'rails', '~> 4.2'
gem 'mysql2', '0.4.2'
gem 'sequel-rails'
gem 'sequel', '~> 4.31.0'
gem 'aaf-gumboot', git: 'https://github.com/ausaccessfed/aaf-gumboot.git',
                   branch: 'develop'
gem 'accession'

gem 'nokogiri'
gem 'xmldsig'

gem 'resque'
gem 'resque-retry'
gem 'redis'
gem 'redis-rails'

gem 'implicit-schema'

gem 'recursive-open-struct'

# Web
gem 'uglifier', '>= 1.3.0'
gem 'therubyracer', platforms: :ruby

# JSON
gem 'jbuilder'

# Security
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1'

# Deployment
gem 'god', require: false
gem 'unicorn', require: false

group :development, :test do
  gem 'rspec-rails', '~> 3.1'
  gem 'rspec-retry'
  gem 'shoulda-matchers'
  gem 'rspec_sequel_matchers', git: 'https://github.com/bradleybeddoes/rspec_sequel_matchers.git'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'fakeredis', require: false
  gem 'capybara', '~> 2.4'
  gem 'timecop', '~> 0.7'
  gem 'webmock', require: false
  gem 'rubocop', require: false
  gem 'simplecov', require: false
  gem 'codeclimate-test-reporter', require: false
  gem 'guard', require: false
  gem 'guard-bundler', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-rspec', require: false
  gem 'guard-brakeman', require: false
  gem 'pry-rails'
  gem 'pry-byebug'
end
