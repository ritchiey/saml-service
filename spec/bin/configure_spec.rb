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
end
