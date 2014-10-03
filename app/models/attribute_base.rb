class AttributeBase < Sequel::Model
  one_to_one :name_format

  def validate
    super
    validates_presence [:name, :oid, :description, :created_at, :updated_at]
  end
end
