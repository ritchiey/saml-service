class Organization < Sequel::Model
  one_to_many :organization_names
  one_to_many :organization_display_names
  # one_to_many :organization_urls

  # Additional to SAML model for our purposes
  one_to_many :entity_descriptors
  one_to_many :role_descriptors

  def validate
    super
    validates_presence [:created_at, :updated_at]

    return if new?
    validates_presence :organization_names, allow_missing: false
    validates_presence :organization_display_names, allow_missing: false
  end
end
