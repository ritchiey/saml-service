# frozen_string_literal: true

Rails.application.configure do
  config.saml_service =
    RecursiveOpenStruct.new({
      metadata: {
        negative_cache_ttl: 600
      },
      api: {
        authentication: :token
      }
    }.deep_symbolize_keys)
end
