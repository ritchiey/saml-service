class SPSSODescriptor < SSODescriptor
  one_to_many :assertion_consumer_services
  one_to_many :attribute_consuming_services

  def validate
    super
    validates_presence [:authn_requests_signed, :want_assertions_signed]

    return if new?
    validates_presence :assertion_consumer_services, allow_missing: false
  end
end
