require 'rails_helper'

RSpec.describe Keypair do
  def pem_jumble(pem)
    parts = pem.split("\n").map do |s|
      next s if s.start_with?('-----') || s.start_with?('MII')
      s.reverse
    end

    parts.join("\n")
  end

  let(:key) { create(:rsa_key) }
  let(:certificate) { create(:certificate, rsa_key: key) }
  let(:other_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:mismatched_certificate) { create(:certificate, rsa_key: other_key) }
  let(:invalid_cert) { pem_jumble(certificate.to_pem) }
  let(:invalid_key) { pem_jumble(key.to_pem) }

  subject { build(:keypair, key: key.to_pem, certificate: certificate.to_pem) }

  context 'validations' do
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence(:key) }
    it { is_expected.to validate_max_length(4096, :key) }
    it { is_expected.to validate_presence(:certificate) }
    it { is_expected.to validate_max_length(4096, :certificate) }

    it 'rejects an invalid certificate' do
      subject.certificate = invalid_cert
      expect(subject).not_to be_valid
    end

    it 'rejects an invalid key' do
      subject.key = invalid_key
      expect(subject).not_to be_valid
    end

    it 'rejects a mismatched keypair' do
      subject.certificate = mismatched_certificate
      expect(subject).not_to be_valid
    end
  end
end
