class Keypair < Sequel::Model
  def validate
    super

    validates_presence [:certificate, :key]
    validates_max_length 4096, [:certificate, :key]

    validate_keypair_content
  end

  def validate_keypair_content
    cert = validate_certificate
    key = validate_key

    return if cert.nil? || key.nil?
    return if cert.public_key.params == key.public_key.params

    errors.add(:certificate, 'does not match the private key')
  end

  def validate_certificate
    OpenSSL::X509::Certificate.new(certificate)
  rescue OpenSSL::X509::CertificateError
    errors.add(:certificate, 'is not a valid X.509 certificate')
    nil
  end

  def validate_key
    OpenSSL::PKey::RSA.new(key)
  rescue OpenSSL::PKey::RSAError
    errors.add(:key, 'is not a valid RSA key')
    nil
  end
end
