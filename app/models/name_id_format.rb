class NameIdFormat < SamlURI
  many_to_one :sso_descriptor

  def validate
    super
    validates_presence :sso_descriptor, allow_missing: false
  end
end
