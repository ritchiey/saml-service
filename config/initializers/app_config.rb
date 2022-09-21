# frozen_string_literal: true

Rails.application.configure do
  redis_user = ENV.fetch('REDIS_AUTH_TOKEN', nil).present? ? ":#{CGI.escape(ENV.fetch('REDIS_AUTH_TOKEN', nil))}@" : ''
  config.saml_service =
    RecursiveOpenStruct.new({
      metadata: {
        negative_cache_ttl: 600
      },
      api: {
        authentication: :token
      },
      url_options: {
        base_url: ENV.fetch('BASE_URL', nil)
      },
      redis: {
        url: "#{ENV.fetch('REDIS_SCHEME', 'redis')}://#{redis_user}#{ENV.fetch('REDIS_HOST', 'localhost')}:6379/0"
      },
      version: "#{ENV.fetch('RELEASE_VERSION', 'OWO')}-#{ENV.fetch('SERIAL_NUMBER', 1)}"
    }.deep_symbolize_keys)
end
