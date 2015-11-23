json.ignore_nil!

json.identity_providers(@identity_providers) do |idp|
  idp_sso_descriptor = idp.idp_sso_descriptors.first
  ui_info = idp_sso_descriptor.ui_info
  disco_hints = idp_sso_descriptor.disco_hints

  json.entity_id idp.entity_id.uri

  display_names = ui_info.try(:display_names) || []
  json.names(display_names, :value, :lang)

  json.tags(idp_sso_descriptor.tags.map(&:name))

  logos = ui_info.try(:logos) || []
  json.logos(logos, :uri, :lang)

  descriptions = ui_info.try(:descriptions) || []
  json.descriptions(descriptions, :value, :lang)

  geolocations = disco_hints.try(:geolocation_hints) || []
  json.geolocations(geolocations, :latitude, :longitude, :altitude)

  domains = disco_hints.try(:domain_hints) || []
  json.domains(domains.map(&:domain))
end
