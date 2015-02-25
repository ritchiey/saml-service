class KnownEntity < Sequel::Model
  many_to_one :entity_source
  one_to_one :entity_descriptor
  one_to_one :raw_entity_descriptor

  def validate
    super
    validates_presence [:entity_source, :active, :created_at, :updated_at]
  end
end
