require 'openssl'

FactoryGirl.define do
  subject = "CN=#{Faker::Lorem.word}/DC=#{Faker::Lorem.word}"
  issuer = "CN=#{Faker::Lorem.word}/DC=#{Faker::Lorem.word}"
  trait :base_key_info do
    expiry Time.now + 3600
    data { generate_certificate subject }
  end

  trait :with_name do
    key_name { Faker::Lorem.word }
  end

  trait :with_subject do
    subject { subject }
  end

  trait :with_issuer do
    issuer { issuer }
  end

  factory :ca_key_info, class: 'CaKeyInfo' do
    base_key_info
    entities_descriptor
  end
  factory :key_info do
    base_key_info
  end
end

def generate_certificate(subject)
  key = OpenSSL::PKey::RSA.new(1024)
  public_key = key.public_key

  cert = OpenSSL::X509::Certificate.new
  cert.subject = cert.issuer = OpenSSL::X509::Name.parse(subject)
  cert.public_key = public_key
  specify_certificate_defaults cert

  cert.sign key, OpenSSL::Digest::SHA1.new
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
