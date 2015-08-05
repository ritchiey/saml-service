module QueryFederationRegistry
  def fr_entity_descriptors
    data(fr_source.entity_descriptors_url)[:entity_descriptors]
  end

  def fr_identity_providers
    data_by_id(fr_source.identity_providers_url, :identity_providers)
  end

  def fr_service_providers
    data_by_id(fr_source.service_providers_url, :service_providers)
  end

  def fr_attribute_authorities
    data_by_id(fr_source.attribute_authorities_url, :attribute_authorities)
  end

  private

  def data_by_id(url, kind)
    data(url)[kind].reduce({}) { |a, e| a.merge(e[:id] => e) }
  end

  def data(url)
    @cache[url] ||=
      ImplicitSchema.new(JSON.parse(retrieve(url), symbolize_names: true))
  end

  def retrieve(url)
    response = do_request(url)
    return response.body if response.is_a?(Net::HTTPSuccess)

    fail("Unable to update FederationRegistrySource(id=#{source.id} " \
         "url=#{url}). Response was: #{response.code} #{response.message}")
  end

  def do_request(url)
    request = Net::HTTP::Get.new(url)
    request['Authorization'] =
      %(AAF-FR-EXPORT service="saml-service", key="#{fr_source.secret}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    http.request(request)
  end
end
