# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~> 5.0'

gem 'accession'
gem 'mysql2', '0.4.2'
gem 'sequel', '~> 4.31.0'
gem 'sequel-rails'

gem 'nokogiri'
gem 'xmldsig'

gem 'redis'
gem 'redis-rails'
gem 'resque'
gem 'resque-retry'

gem 'implicit-schema'

gem 'recursive-open-struct'

gem 'therubyracer', platforms: :ruby
gem 'uglifier', '>= 1.3.0'

gem 'jbuilder'

gem 'bcrypt', '~> 3.1'

gem 'god', require: false
gem 'unicorn', require: false

group :development, :test do
  gem 'capybara', '~> 2.4'
  gem 'rspec-rails', '~> 3.1'
  gem 'rspec-retry'
  gem 'webmock', require: false

  gem 'aaf-gumboot', git: 'https://github.com/ausaccessfed/aaf-gumboot.git',
                     branch: 'develop'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'rails-controller-testing'
  gem 'rspec_sequel_matchers', git: 'https://github.com/bradleybeddoes/rspec_sequel_matchers.git'
  gem 'shoulda-matchers'

  gem 'codeclimate-test-reporter', require: false
  gem 'fakeredis', require: false
  gem 'simplecov', require: false
  gem 'timecop', '~> 0.7'

  gem 'guard', require: false
  gem 'guard-brakeman', require: false
  gem 'guard-bundler', require: false
  gem 'guard-rspec', require: false
  gem 'guard-rubocop', require: false
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rubocop', require: false
end
