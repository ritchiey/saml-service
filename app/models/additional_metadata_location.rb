class AdditionalMetadataLocation < Sequel::Model
  many_to_one :entity_descriptor
  def validate
    super
    validates_presence [:uri, :namespace, :created_at, :updated_at]
  end
end
