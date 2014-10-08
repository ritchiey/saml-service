class EntityId < SamlURI
  many_to_one :entity_descriptor

  def validate
    super
    validates_presence :entity_descriptor, allow_missing: false
    validates_max_length 1024, :uri
  end
end
