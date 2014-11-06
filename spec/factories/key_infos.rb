require 'openssl'

FactoryGirl.define do
  subject = "CN=#{Faker::Lorem.word}/DC=#{Faker::Lorem.word}"
  issuer = "CN=#{Faker::Lorem.word}/DC=#{Faker::Lorem.word}"
  trait :base_key_info do
    key_name { Faker::Lorem.word }
    expiry Time.now + 3600
    subject { subject }
    issuer { issuer }
    data { generate_certificate subject, issuer }
  end

  factory :ca_key_info, class: 'CaKeyInfo', traits: [:base_key_info]
  factory :key_info do
    base_key_info
  end
end

def generate_certificate(subject, issuer)
  cert = OpenSSL::X509::Certificate.new
  cert.subject = OpenSSL::X509::Name.parse subject
  cert.issuer = OpenSSL::X509::Name.parse issuer
  cert.public_key = generate_key.public_key

  specify_certificate_defaults cert

  cert.to_pem
end

def specify_certificate_defaults(cert)
  cert.not_before = Time.now
  cert.not_after = Time.now + 3600
  cert.serial = 0x0
  cert.version = 2
end

def generate_key
  OpenSSL::PKey::RSA.new 1024
end
