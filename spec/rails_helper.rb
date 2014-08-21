# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require 'spec_helper'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.include FactoryGirl::Syntax::Methods

  # Use Sequel matchers and transactions
  config.include RspecSequel::Matchers
  config.around(:each) do |spec|
    Sequel::Model.db.transaction(rollback: :always,
                                 auto_savepoint: true) { spec.run }
  end

  config.infer_spec_type_from_file_location!
end
