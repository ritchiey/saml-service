require 'openssl'

FactoryGirl.define do
  factory :ca_key_info do
    data { generate_certificate }
    key_name { Faker::Lorem.word }
    expiry Time.now + 3600

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
