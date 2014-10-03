class AttributeProfile < SamlURI
  many_to_one :idp_sso_descriptor
end
