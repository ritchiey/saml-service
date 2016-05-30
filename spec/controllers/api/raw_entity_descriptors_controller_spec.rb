# frozen_string_literal: true
require 'rails_helper'

RSpec.describe API::RawEntityDescriptorsController, type: :controller do
  describe 'post :create' do
    let(:entity_source) { create(:entity_source) }
    let(:source_tag) { entity_source.source_tag }

    let(:tags) { [Faker::Lorem.word, Faker::Lorem.word] }
    let(:host_name) { Faker::Internet.domain_name }
    let(:entity_id) { "https://#{host_name}/shibboleth" }
    let(:enabled) { [true, false].sample }
    let(:xml) do
      <<-EOF.strip_heredoc
          <EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
            xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
            entityID="#{entity_id}">
            <IDPSSODescriptor
              protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
              <SingleSignOnService
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"
                Location="https://#{host_name}/idp/profile/SAML2/Redirect/SSO"/>
            </IDPSSODescriptor>
          </EntityDescriptor>
        EOF
    end

    let(:raw_entity_descriptor) do
      { xml: xml, tags: tags, entity_id: entity_id, enabled: enabled }
    end

    def run
      if api_subject
        request.env['HTTP_X509_DN'] = "CN=#{api_subject.x509_cn}".dup
      end

      post :create, tag: source_tag,
                    raw_entity_descriptor: raw_entity_descriptor
    end

    def swallow
      yield
    rescue
      nil
    end

    context 'not permitted' do
      let(:api_subject) { create(:api_subject) }
      before { run }
      subject { response }
      it { is_expected.to have_http_status(:forbidden) }
      it 'responds with a message' do
        data = JSON.load(response.body)
        expect(data['message']).to match(/explicitly denied/)
      end
    end

    context 'permitted' do
      let(:api_subject) { create(:api_subject, :authorized, permission: '*') }

      subject do
        run
        response
      end

      context 'with an entity source that does not exist' do
        let(:source_tag) { Faker::Lorem.word }
        it { is_expected.to have_http_status(:not_found) }
      end

      context 'with valid params' do
        it { is_expected.to have_http_status(:created) }

        context 'raw entity descriptors' do
          subject { -> { run } }
          it { is_expected.to change(RawEntityDescriptor, :count).by(1) }
          context 'record' do
            before { run }
            let(:record) { RawEntityDescriptor.last }
            subject { record }
            it { is_expected.to_not be_nil }

            context 'known entity' do
              subject { record.known_entity }
              it { is_expected.to eq(KnownEntity.last) }
            end

            context 'xml' do
              subject { record.xml }
              it { is_expected.to eq(raw_entity_descriptor[:xml]) }
            end

            context 'enabled' do
              subject { record.enabled }
              it { is_expected.to eq(raw_entity_descriptor[:enabled]) }
            end

            context 'idp' do
              subject { record.idp }
              it { is_expected.to be_truthy }
            end

            context 'sp' do
              subject { record.sp }
              it { is_expected.to be_falsey }
            end

            context 'standalone aa' do
              subject { record.standalone_aa }
              it { is_expected.to be_falsey }
            end
          end
        end

        context 'known entities' do
          subject { -> { run } }
          it { is_expected.to change(KnownEntity, :count).by(1) }

          context 'record' do
            before { run }
            let(:record) { KnownEntity.last }
            subject { record }
            it { is_expected.to_not be_nil }

            context 'enabled' do
              subject { record.enabled }
              it { is_expected.to eq(raw_entity_descriptor[:enabled]) }
            end

            context 'entity source' do
              subject { record.entity_source }
              it { is_expected.to eq(entity_source) }
            end

            context 'tags' do
              subject { record.tags.map(&:name) }
              it { is_expected.to eq(tags) }
            end
          end
        end

        context 'entity ids' do
          subject { -> { run } }
          it { is_expected.to change(EntityId, :count).by(1) }

          context 'record' do
            before { run }
            let(:record) { EntityId.last }
            subject { record }
            it { is_expected.to_not be_nil }

            context 'uri' do
              subject { record.uri }
              it { is_expected.to eq(entity_id) }
            end

            context 'description' do
              subject { record.description }
              it { is_expected.to be_nil }
            end

            context 'role descriptor id' do
              subject { record.role_descriptor_id }
              it { is_expected.to be_nil }
            end

            context 'entity descriptor' do
              subject { record.entity_descriptor }
              it { is_expected.to be_nil }
            end

            context 'raw entity descriptor' do
              subject { record.raw_entity_descriptor }
              it { is_expected.to eq(RawEntityDescriptor.last) }
            end

            context 'sha1' do
              subject { record.sha1 }
              it { is_expected.to eq(Digest::SHA1.hexdigest(entity_id)) }
            end
          end
        end
      end

      context 'with empty raw entity descriptor' do
        let(:raw_entity_descriptor) { {} }
        subject { -> { run } }
        it { is_expected.to raise_error(ActionController::ParameterMissing) }
      end

      context 'with missing xml' do
        before { raw_entity_descriptor.delete(:xml) }
        it { is_expected.to have_http_status(:bad_request) }
      end

      context 'with a missing entity id' do
        before { raw_entity_descriptor.delete(:entity_id) }
        it { is_expected.to have_http_status(:bad_request) }
      end

      context 'with missing enabled flag' do
        before { raw_entity_descriptor.delete(:enabled) }
        it { is_expected.to have_http_status(:bad_request) }
      end

      context 'with missing tags' do
        before { raw_entity_descriptor.delete(:tags) }
        it { is_expected.to have_http_status(:bad_request) }
      end

      RSpec.shared_examples 'no state changed' do
        context 'known entities' do
          subject { -> { run } }
          it { is_expected.to_not change(KnownEntity, :count) }
        end

        context 'raw entity descriptors' do
          subject { -> { run } }
          it { is_expected.to_not change(RawEntityDescriptor, :count) }
        end

        context 'entity ids' do
          subject { -> { run } }
          it { is_expected.to_not change(EntityId, :count) }
        end
      end

      context 'with an invalid enabled flag' do
        let(:enabled) { Faker::Lorem.characters }
        it { is_expected.to have_http_status(:bad_request) }
        it_behaves_like 'no state changed'
      end

      context 'with invalid entity id' do
        let(:entity_id) { Faker::Lorem.characters }
        it { is_expected.to have_http_status(:bad_request) }
        it_behaves_like 'no state changed'
      end

      context 'with invalid tags' do
        let(:tags) { ['@*!', '^'] }
        it { is_expected.to have_http_status(:bad_request) }
        it_behaves_like 'no state changed'
      end

      context 'with invalid xml' do
        let(:xml) do
          <<-EOF.strip_heredoc
            <IDPSSODescriptor
              protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
              <SingleSignOnService
                Binding="urn:oasis:names:tc:SAML:2.0:bindings:SOAP"
                Location="https://#{host_name}/idp/profile/SAML2/Redirect/SSO"/>
            </IDPSSODescriptor>
          EOF
        end

        subject { -> { run } }
        it { is_expected.to raise_error(Sequel::ValidationFailed) }

        context 'known entities' do
          subject { -> { swallow { run } } }
          it { is_expected.to_not change(KnownEntity, :count) }
        end

        context 'raw entity descriptors' do
          subject { -> { swallow { run } } }
          it { is_expected.to_not change(RawEntityDescriptor, :count) }
        end

        context 'entity ids' do
          subject { -> { swallow { run } } }
          it { is_expected.to_not change(EntityId, :count) }
        end
      end
    end
  end
end
