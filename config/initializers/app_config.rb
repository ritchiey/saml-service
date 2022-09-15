# frozen_string_literal: true

Rails.application.configure do
  config.saml_service =
    RecursiveOpenStruct.new({
      metadata: {
        negative_cache_ttl: 600
      },
      api: {
        authentication: :token
      },
      sentry: {
        dsn: ENV.fetch('SENTRY_DSN', nil)
      },
      url_options: {
        base_url: ENV.fetch('BASE_URL', nil)
      },
      version: "#{ENV.fetch('RELEASE_VERSION', 'dsa23gv23gvy32gh')}-#{ENV.fetch('SERIAL_NUMBER', 1)}"
    }.deep_symbolize_keys)
end
