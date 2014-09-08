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

    to_create { |i| i.save }
  end

  factory :ca_key_info, class: 'CaKeyInfo', traits: [:base_key_info]
  factory :key_info do
    base_key_info
  end
end

def generate_certificate(subject, issuer)
  key = OpenSSL::PKey::RSA.new 1024

  cert = OpenSSL::X509::Certificate.new
  cert.subject = OpenSSL::X509::Name.parse subject
  cert.issuer = OpenSSL::X509::Name.parse issuer
  cert.not_before = Time.now
  cert.not_after = Time.now + 3600
  cert.public_key = key.public_key
  cert.serial = 0x0
  cert.version = 2

  cert.to_pem
end
