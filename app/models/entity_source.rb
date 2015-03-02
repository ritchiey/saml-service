class EntitySource < Sequel::Model
  one_to_many :known_entities

  def entity_descriptors
    known_entities.map(&:entity_descriptor)
  end

  def validate
    super
    validates_presence [:rank, :active, :created_at, :updated_at]
    validates_integer :rank
    validates_unique :rank
    validate_url
    validate_certificate
  end

  def validate_url
    return if url.nil?

    validates_format URI.regexp(%w(http https)), :url
    URI.parse(url)
  rescue URI::InvalidURIError
    errors.add(:url, 'could not be parsed as a valid URI')
  end

  def validate_certificate
    return if certificate.nil?

    OpenSSL::X509::Certificate.new(certificate)
  rescue OpenSSL::X509::CertificateError
    errors.add(:certificate, 'is not a valid PEM format X.509 certificate')
  end
end
