# frozen_string_literal: true

require File.expand_path('boot', __dir__)

# Pick the frameworks you want:
require 'active_model/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
# require 'sprockets/railtie'
# require 'active_record/railtie'
# require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Sequel.default_timezone = :utc

module Saml
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those
    # specified here.

    config.load_defaults 6.0
    config.autoloader = :zeitwerk

    config.sequel.after_connect = proc do
      Sequel::Model.db.extension :connection_validator
      Sequel::Model.db.pool.connection_validation_timeout = -1
      Sequel::Model.plugin :timestamps, update_on_create: true
      Sequel::Model.plugin :validation_helpers
    end

    if ENV['REDIS_AUTH_TOKEN'].present?
      config.cache_store = :redis_cache_store, {
        url: "#{ENV.fetch('REDIS_SCHEME', 'rediss')}://:#{CGI.escape(ENV.fetch('REDIS_AUTH_TOKEN', 'password'))}@" \
             "#{ENV.fetch('REDIS_HOST', 'localhost')}:6379/0",
        ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE },
        namespace: 'val',
        pool_size: 5,
        pool_timeout: 5
      }
    ## this is the legacy config can be removed once nnwo is used for live
    else
      config.cache_store = :redis_store, 'redis://localhost:6379/0/cache'
    end
    config.autoload_paths << Rails.root.join('app', 'jobs', 'concerns')

    config.sequel.logger = Logger.new($stderr) if ENV['AAF_DEBUG']

    config.force_ssl
  end
end
