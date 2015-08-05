require 'implicit_schema'

class UpdateFromFederationRegistry
  include QueryFederationRegistry
  include StoreFederationRegistryData

  attr_reader :fr_source, :source

  def self.perform(id)
    new(id).perform
  end

  def initialize(id)
    @cache = {}
    @fr_source = FederationRegistrySource[id]
    @source = @fr_source.entity_source
  end

  def perform
    fr_entity_descriptors.each do |ed|
      entity_descriptor(ed)
    end
  end

  private

  def entity_descriptor(ed_data)
    ds = EntityDescriptor.dataset
    ed = create_or_update_by_fr_id(ds, ed_data[:id]) do |obj|
      obj.known_entity = KnownEntity.create(entity_source: source,
                                            active: ed_data[:active])
    end

    entity_id(ed, ed_data)
    idp_sso_descriptors(ed, ed_data)
  end

  def entity_id(ed, ed_data)
    return ed.entity_id.update(uri: ed_data[:entity_id]) if ed.entity_id
    EntityId.create(uri: ed_data[:entity_id], entity_descriptor: ed)
  end

  def idp_sso_descriptors(ed, ed_data)
    ed_data[:saml][:identity_providers].each do |idp_ref|
      idp_data = fr_identity_providers[idp_ref[:id]]
      idp_sso_descriptor(ed, idp_data)
    end
  end

  def idp_sso_descriptor(ed, idp_data)
    attrs = idp_attrs(idp_data)
    ds = ed.idp_sso_descriptors_dataset

    _idp = create_or_update_by_fr_id(ds, idp_data[:id], attrs) do |obj|
      obj.entity_descriptor = ed
    end
  end

  def idp_attrs(idp_data)
    role_descriptor = idp_data[:saml][:sso_descriptor][:role_descriptor]

    {
      want_authn_requests_signed: idp_data[:saml][:authnrequests_signed],
      active: idp_data[:active],
      created_at: Time.parse(idp_data[:created_at]),
      error_url: role_descriptor[:error_url],
      extensions: role_descriptor[:extensions]
    }
  end
end
