class RequestedAttribute < Attribute
  many_to_one :attribute_consuming_service

  def validate
    # super
    validates_presence [:reasoning, :required]
    validates_presence :attribute_consuming_service, allow_missing: false
  end
end
