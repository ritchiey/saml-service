require 'openssl'

FactoryGirl.define do
  factory :ca_certificate do
    data { generate_certificate }

    to_create { |i| i.save }
  end
end

def generate_certificate
  key = OpenSSL::PKey::RSA.new 1024
  public_key = key.public_key

  cert = OpenSSL::X509::Certificate.new
  cert.subject = cert.issuer = OpenSSL::X509::Name.parse 'DC=example,DC=com'
  cert.not_before = Time.now
  cert.not_after = Time.now + 3600
  cert.public_key = public_key
  cert.serial = 0x0
  cert.version = 2

  cert.to_pem
end
