class RequestedAttribute < Attribute
  def validate
    super
    validates_presence [:reasoning, :required]
  end
end
