FactoryGirl.define do
  TEST_RSA_KEYS = {}

  factory :rsa_key, class: OpenSSL::PKey::RSA do
    transient { bits 2048 }

    initialize_with do
      TEST_RSA_KEYS[bits.to_i] ||= OpenSSL::PKey::RSA.new(bits)
    end

    skip_create
  end

  factory :certificate, class: OpenSSL::X509::Certificate do
    transient do
      rsa_key { create(:rsa_key) }
      dn { "CN=#{SecureRandom.urlsafe_base64}" }
      digest_class OpenSSL::Digest::SHA256
    end

    public_key { rsa_key.public_key }
    issuer { OpenSSL::X509::Name.parse(dn) }
    subject { issuer }

    not_before { Time.now }
    not_after { 1.hour.from_now }
    serial 0
    version 2

    after(:build) do |cert, attr|
      cert.sign(attr.rsa_key, attr.digest_class.new)
    end

    skip_create
  end

  factory :keypair do
    transient { rsa_key { create(:rsa_key) } }

    certificate { create(:certificate, rsa_key: rsa_key).to_pem }
    key { rsa_key.to_pem }
  end
end
