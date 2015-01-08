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
      before { subject.root_entities_descriptor }

      it 'creates EntitiesDescriptor node' do
        path = '/EntitiesDescriptor[@ID and @Name and @validUntil]'
        expect(xml).to have_xpath(path)
      end

      it 'defines all namespaces' do
        expect(namespaces).to eq(Metadata::SAML::NAMESPACES)
      end

      context 'has valid attributes' do
        let(:node) { xml.find(:xpath, '/EntitiesDescriptor') }

        before { Timecop.freeze }
        after { Timecop.return }

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
  end
end
