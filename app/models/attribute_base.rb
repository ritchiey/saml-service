class AttributeBase < Sequel::Model
  many_to_one :name_format, class: :SamlURI

  def validate
    super
    validates_presence [:name, :legacy_name, :oid, :description, :name_format,
                        :created_at, :updated_at]
  end
end
