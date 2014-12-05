source 'https://rubygems.org'

# Core
gem 'rails', '4.1.8'
gem 'mysql2'
gem 'sequel-rails'

# Web
gem 'uglifier', '>= 1.3.0'
gem 'therubyracer',  platforms: :ruby
gem 'turbolinks'

# JSON
gem 'jbuilder'

# Security
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1'

# Deployment
gem 'unicorn', require: false

group :development, :test do
  gem 'rspec-rails', '~> 3.1.0'
  gem 'shoulda-matchers'
  gem 'rspec_sequel_matchers', git: 'https://github.com/bradleybeddoes/rspec_sequel_matchers.git'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'coveralls'
  gem 'rubocop', require: false
  gem 'simplecov', require: false
  gem 'guard', require: false
  gem 'guard-bundler', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-rspec', require: false
  gem 'guard-brakeman', require: false
  gem 'pry-rails', require: false
end
