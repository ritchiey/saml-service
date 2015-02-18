class SPSSODescriptor < SSODescriptor
  one_to_many :assertion_consumer_services
  one_to_many :attribute_consuming_services

  def validate
    super
    validates_presence [:authn_requests_signed, :want_assertions_signed]
    validates_presence :assertion_consumer_services, allow_missing: new?
  end

  def attribute_consuming_services?
    attribute_consuming_services.try(:present?)
  end

  def self.with_any_tag(tags)
    Tag.where(name: tags).exclude(role_descriptor_id: nil).all
      .select do |tag|
        tag.role_descriptor && tag.role_descriptor.is_a?(SPSSODescriptor)
      end
      .map(&:role_descriptor).uniq
  end
end
