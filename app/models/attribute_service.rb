class AttributeService < Endpoint
  many_to_one :attribute_authority_descriptor

  def validate
    super
    validates_presence :attribute_authority_descriptor, allow_missing: false
  end
end
