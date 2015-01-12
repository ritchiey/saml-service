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
    let(:federation_identifier) { Faker::Internet.domain_word }
    let(:metadata_name) { "urn:mace:#{federation_identifier}.edu:test" }
    let(:metadata_validity_period) { 1.weeks }

    before :each do
      subject.federation_identifier = federation_identifier
      subject.metadata_name = metadata_name
      subject.metadata_validity_period = metadata_validity_period
    end

    context 'minimal instance' do
      let(:entities_descriptor) { create :basic_federation }
      let(:namespaces) { Nokogiri::XML.parse(raw_xml).collect_namespaces }

      context 'EntitiesDescriptor' do
        before { subject.root_entities_descriptor(entities_descriptor) }
        it 'is created' do
          path = '/EntitiesDescriptor[@ID and @Name and @validUntil]'
          expect(xml).to have_xpath(path)
        end

        it 'defines namespaces' do
          expect(namespaces).to eq(Metadata::SAML::NAMESPACES)
        end

        context 'attributes' do
          let(:node) { xml.find(:xpath, '/EntitiesDescriptor') }

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
      end

      context 'CA keys' do
        let(:extensions_path) { '/EntitiesDescriptor/Extensions' }
        let(:key_authority_path) { "#{extensions_path}/shibmd:KeyAuthority" }
        let(:key_info_path) { "#{key_authority_path}/ds:KeyInfo" }

        context 'without CA keys' do
          before { subject.root_entities_descriptor(entities_descriptor) }

          it 'does not populate Extensions node' do
            expect(xml).not_to have_xpath(extensions_path)
          end
        end

        context 'with CA keys' do
          let(:ca_key_info) do
            create :ca_key_info, entities_descriptor: entities_descriptor
          end
          let(:ca_key_info2) do
            create :ca_key_info, key_name: nil,
                                 entities_descriptor: entities_descriptor
          end
          before do
            entities_descriptor.add_ca_key_info(ca_key_info)
            entities_descriptor.add_ca_key_info(ca_key_info2)
            subject.root_entities_descriptor(entities_descriptor)
          end

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
  end

  context 'KeyInfo' do
    let(:key_info) { create :key_info }
    let(:key_info_path) { '/ds:KeyInfo' }
    let(:key_name_path) { "#{key_info_path}/ds:KeyName" }
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
  end
end
