class IDPSSODescriptor < SSODescriptor
  one_to_many :single_sign_on_services
  one_to_many :name_id_mapping_services
  one_to_many :assertion_id_request_services
  one_to_many :attribute_profiles
  one_to_many :attributes

  one_to_one :disco_hints, class: 'MDUI::DiscoHints'

  def validate
    super
    validates_presence [:want_authn_requests_signed]
    validates_presence :single_sign_on_services, allow_missing: new?
  end

  def extensions?
    extensions.try(:present?) || ui_info.present? || disco_hints.present?
  end

  def name_id_mapping_services?
    name_id_mapping_services.try(:present?)
  end

  def assertion_id_request_services?
    assertion_id_request_services.try(:present?)
  end

  def attribute_profiles?
    attribute_profiles.try(:present?)
  end

  def attributes?
    attributes.try(:present?)
  end

  def disco_hints?
    disco_hints.try(:present?)
  end
end
