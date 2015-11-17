require 'rails_helper'
require_relative '../../bin/configure'

RSpec.describe ConfigureCLI do
  describe '#fr_source' do
    def run(hostname, secret)
      ConfigureCLI.start(['fr_source',
                          '--hostname', hostname,
                          '--secret', secret])
    end

    context 'when multiple sources exist' do
      let!(:fr_sources) { create_list(:federation_registry_source, 2) }

      it 'raises an error' do
        expect { run('a', 'b') }
          .to raise_error('Multiple FederationRegistrySource objects exist')
      end
    end

    context 'when a source exists' do
      let!(:fr_source) { create(:federation_registry_source) }

      it 'updates the secret' do
        new_secret = SecureRandom.urlsafe_base64
        expect { run(fr_source.hostname, new_secret) }
          .to change { fr_source.reload.secret }.to(new_secret)
      end

      it 'updates the hostname' do
        new_hostname = "manager.#{Faker::Internet.domain_name}"
        expect { run(new_hostname, fr_source.secret) }
          .to change { fr_source.reload.hostname }.to(new_hostname)
      end
    end

    context 'when no source exists' do
      let(:hostname) { Faker::Internet.domain_name }
      let(:secret) { SecureRandom.urlsafe_base64 }

      it 'creates a new source' do
        expect { run(hostname, secret) }
          .to change(FederationRegistrySource, :count).by(1)
      end

      it 'creates an active EntitySource' do
        expect { run(hostname, secret) }
          .to change(EntitySource, :count).by(1)

        expect(EntitySource.last).to have_attributes(active: true, rank: 10)
      end

      it 'sets the correct registration attributes on the new source' do
        run(hostname, secret)
        expected = {
          registration_authority: "https://#{hostname}/federationregistry/",
          registration_policy_uri: "https://#{hostname}/federationregistry/",
          registration_policy_uri_lang: 'en'
        }
        expect(FederationRegistrySource.last).to have_attributes(expected)
      end
    end
  end

  describe '#keypair' do
    let(:cert_file) { '/nonexistent/path/to/cert.pem' }
    let(:key_file) { '/nonexistent/path/to/key.pem' }

    let(:rsa_key) { create(:rsa_key) }
    let(:x509_certificate) { create(:certificate, rsa_key: rsa_key) }

    before do
      allow(File).to receive(:read).with(cert_file)
        .and_return(x509_certificate.to_pem)
      allow(File).to receive(:read).with(key_file).and_return(rsa_key.to_pem)
    end

    def run
      ConfigureCLI.start(['keypair',
                          '--cert', cert_file,
                          '--key', key_file])
    end

    context 'when the keypair exists' do
      let!(:keypair) do
        create(:keypair, x509_certificate: x509_certificate, rsa_key: rsa_key)
      end

      it 'creates no new keypair' do
        expect { run }.not_to change(Keypair, :count)
      end

      it 'does not change the existing keypair' do
        attrs = -> { keypair.reload && [keypair.certificate, keypair.key] }
        expect { run }.not_to change(&attrs)
      end
    end

    context 'when no keypair exists' do
      it 'creates a keypair' do
        expect { run }.to change(Keypair, :count).by(1)

        expected = { certificate: x509_certificate.to_pem, key: rsa_key.to_pem }
        expect(Keypair.last).to have_attributes(expected)
      end
    end
  end
end
