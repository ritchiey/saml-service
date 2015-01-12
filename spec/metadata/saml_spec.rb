require 'rails_helper'

require 'metadata/saml'

RSpec.describe Metadata::SAML do
  let(:builder) { subject.builder }
  let(:raw_xml) { builder.to_xml }
  let(:xml) do
    # Pull out xmlns so our tests don't need to specify it everywhere
    # as we expect metadata nodes to live under this namespace by default
    raw_xml.sub!('xmlns="urn:oasis:names:tc:SAML:2.0:metadata"', '')
    Capybara::Node::Simple.new(Nokogiri::XML.parse(raw_xml))
  end

  include_examples 'SAML namespaces'

  it 'renders xml' do
    expect(subject.to_xml).to eq(raw_xml)
  end

  context 'Root EntitiesDescriptor' do
    let(:entities_descriptor) { create :basic_federation }
    let(:add_ca_keys) { true }

    let(:federation_identifier) { Faker::Internet.domain_word }
    let(:metadata_name) { "urn:mace:#{federation_identifier}.edu:test" }
    let(:metadata_validity_period) { 1.weeks }

    let(:namespaces) { Nokogiri::XML.parse(raw_xml).collect_namespaces }

    let(:entities_descriptor_path) { '/EntitiesDescriptor' }
    let(:extensions_path) { '/EntitiesDescriptor/Extensions' }
    let(:key_authority_path) { "#{extensions_path}/shibmd:KeyAuthority" }
    let(:key_info_path) { "#{key_authority_path}/ds:KeyInfo" }

    before :each do
      subject.federation_identifier = federation_identifier
      subject.metadata_name = metadata_name
      subject.metadata_validity_period = metadata_validity_period
      create_list(:ca_key_info, 2,
                  entities_descriptor: entities_descriptor) if add_ca_keys

      subject.root_entities_descriptor(entities_descriptor)
    end

    it 'is created' do
      expect(xml).to have_xpath(entities_descriptor_path)
    end

    it 'defines namespaces' do
      expect(namespaces).to eq(Metadata::SAML::NAMESPACES)
    end

    context 'attributes' do
      let(:node) { xml.find(:xpath, entities_descriptor_path) }

      around { |example| Timecop.freeze { example.run } }

      it 'sets ID' do
        expect(node['ID']).to start_with(federation_identifier)
      end
      it 'sets Name' do
        expect(node['Name']).to eq(metadata_name)
      end
      it 'sets validUntil' do
        expect(node['validUntil'])
          .to eq((Time.now.utc + metadata_validity_period).xmlschema)
      end
    end

    context 'CA keys' do
      context 'without CA keys' do
        let(:add_ca_keys) { false }
        it 'does not populate Extensions node' do
          expect(xml).not_to have_xpath(extensions_path)
        end
      end

      context 'with CA keys' do
        context 'Extensions' do
          it 'is created' do
            expect(xml).to have_xpath(extensions_path)
          end
          context 'KeyAuthority' do
            it 'is created' do
              expect(xml).to have_xpath(key_authority_path)
            end
            context 'attributes' do
              let(:node) { xml.find(:xpath, key_authority_path) }
              it 'sets VerifyDepth' do
                expect(node['VerifyDepth'])
                  .to eq(entities_descriptor.ca_verify_depth.to_s)
              end
            end
            context 'KeyInfo' do
              it 'creates two instances' do
                expect(xml).to have_xpath(key_info_path, count: 2)
              end
            end
          end
        end
      end
    end
  end

  context 'KeyInfo' do
    let(:key_info) { create :key_info }
    let(:key_info_path) { '/ds:KeyInfo' }
    let(:key_name_path) { "#{key_info_path}/ds:KeyName" }
    let(:x509_data_path) { "#{key_info_path}/ds:X509Data" }
    let(:x509_subject_name_path) { "#{x509_data_path}/ds:X509SubjectName" }
    let(:x509_certificate_path) { "#{x509_data_path}/ds:X509Certificate" }

    before { subject.key_info(key_info) }

    it 'is created' do
      expect(xml).to have_xpath(key_info_path)
    end

    context 'KeyName' do
      context 'is set' do
        let(:node) { xml.find(:xpath, key_name_path) }
        it 'is created' do
          expect(xml).to have_xpath(key_name_path)
        end
        it 'has correct value' do
          expect(node.text).to eq(key_info.key_name)
        end
      end
      context 'is not set' do
        let(:key_info) { create :key_info, key_name: nil }
        it 'is not created' do
          expect(xml).not_to have_xpath(key_name_path)
        end
      end
    end

    context 'X509Data' do
      it 'is created' do
        expect(xml).to have_xpath(x509_data_path)
      end
      context 'X509SubjectName' do
        let(:node) { xml.find(:xpath, x509_subject_name_path) }
        it 'is created' do
          expect(xml).to have_xpath(x509_subject_name_path)
        end
        it 'has correct value' do
          expect(node.text).to eq(key_info.subject)
        end
      end
      context 'X509Certificate' do
        let(:node) { xml.find(:xpath, x509_certificate_path) }
        it 'is created' do
          expect(xml).to have_xpath(x509_certificate_path)
        end
        it 'has correct value' do
          expect(node.text).to eq(key_info.certificate_without_anchors)
        end
      end
    end
  end
end
