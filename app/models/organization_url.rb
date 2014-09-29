class OrganizationURL < LocalizedURI
  many_to_one :organization

  def validate
    super
    validates_presence :organization, allow_missing: false
  end
end
