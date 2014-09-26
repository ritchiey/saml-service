class AttributeConsumingService < Sequel::Model
  many_to_one :sp_sso_descriptor
  one_to_many :service_names
  one_to_many :service_descriptions
  one_to_many :requested_attributes

  def validate
    super
    validates_presence [:created_at, :updated_at]
    validates_presence :index, allow_missing: false
    validates_presence :default, allow_missing: false
    validates_presence :sp_sso_descriptor, allow_missing: false

    return if new?
    validates_presence :service_names, allow_missing: false
    validates_presence :requested_attributes, allow_missing: false
  end
end
