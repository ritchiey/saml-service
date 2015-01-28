RSpec.shared_examples 'EntitiesDescriptor xml' do
  let(:add_ca_keys) { false }
  let(:add_registration_info) { false }
  let(:add_entity_attributes) { false }
  let(:add_child_entities_descriptors) { false }
  let(:namespaces) { Nokogiri::XML.parse(raw_xml).collect_namespaces }

  let(:entities_descriptor_path) { '/EntitiesDescriptor' }
  let(:extensions_path) { "#{entities_descriptor_path}/Extensions" }
  let(:registration_info_path) { "#{extensions_path}/mdrpi:RegistrationInfo" }
  let(:entity_attributes_path) { "#{extensions_path}/mdattr:EntityAttributes" }

  let(:entity_descriptor_path) do
    "#{entities_descriptor_path}/EntityDescriptor"
  end
  let(:child_entities_descriptors_path) do
    '/EntitiesDescriptor/EntitiesDescriptor'
  end

  before :each do
    if add_ca_keys
      create_list(:ca_key_info, 2, entities_descriptor: entities_descriptor)
    end
    if add_registration_info
      create(:mdrpi_registration_info, entities_descriptor: entities_descriptor)
    end
    if add_entity_attributes
      create(:mdattr_entity_attribute, entities_descriptor: entities_descriptor)
    end
    if add_child_entities_descriptors
      create_list(:child_entities_descriptor, 2,
                  parent_entities_descriptor: entities_descriptor)
    end
  end

  RSpec.shared_examples 'md:EntitiesDescriptor xml' do
    it 'is created' do
      expect(xml).to have_xpath(entities_descriptor_path)
    end

    context 'child EntitiesDescriptors' do
      context 'not defined' do
        it 'does not have child EntitiesDescriptors' do
          expect(xml).not_to have_xpath(child_entities_descriptors_path)
        end
      end

      context 'defined' do
        let(:add_child_entities_descriptors) { true }
        it 'does have child EntitiesDescriptors' do
          expect(xml)
            .to have_xpath(child_entities_descriptors_path, count: 2)
        end
      end
    end

    it 'renders child EntityDescriptors' do
      expect(xml).to have_xpath(entity_descriptor_path, count: 5)
    end

    context 'Extensions' do
      context 'RegistrationInfo set' do
        let(:add_registration_info) { true }
        it 'creates RegistrationInfo node' do
          expect(xml).to have_xpath(registration_info_path, count: 1)
        end
      end
      context 'RegistrationInfo not set' do
        it 'does not create RegistrationInfo node' do
          expect(xml).to have_xpath(registration_info_path, count: 0)
        end
      end

      context 'with EntityAttributes' do
        let(:add_entity_attributes) { true }
        it 'creates EntityAttributes node' do
          expect(xml).to have_xpath(entity_attributes_path, count: 1)
        end
      end
      context 'without EntityAttributes' do
        it 'does not create EntityAttributes node' do
          expect(xml).to have_xpath(entity_attributes_path, count: 0)
        end
      end
    end
  end

  context 'Root EntitiesDescriptor' do
    before { subject.root_entities_descriptor(entities_descriptor) }
    include_examples 'shibmd:KeyAuthority xml'
    include_examples 'md:EntitiesDescriptor xml'

    it 'defines namespaces' do
      expect(namespaces).to eq(Metadata::SAML::NAMESPACES)
    end

    context 'attributes' do
      let(:node) { xml.find(:xpath, entities_descriptor_path) }

      around { |example| Timecop.freeze { example.run } }

      it 'sets ID' do
        expect(node['ID']).to eq(subject.instance_id)
          .and start_with(federation_identifier)
      end
      it 'sets Name' do
        expect(node['Name']).to eq(metadata_name)
      end
      it 'sets validUntil' do
        expect(node['validUntil'])
          .to eq((Time.now.utc + metadata_validity_period).xmlschema)
      end
    end

    context 'Extensions' do
      it 'creates a mdrpi:PublisherInfo' do
        expect(xml).to have_xpath(all_publication_infos, count: 1)
      end
    end
  end

  context 'EntitiesDescriptor' do
    before { subject.entities_descriptor(entities_descriptor) }
    include_examples 'shibmd:KeyAuthority xml'
    include_examples 'md:EntitiesDescriptor xml'

    context 'attributes' do
      let(:node) { xml.find(:xpath, entities_descriptor_path) }

      around { |example| Timecop.freeze { example.run } }

      it 'does not set ID' do
        expect(node['ID']).not_to be
      end
      it 'does not set Name' do
        expect(node['Name']).not_to be
      end
      it 'does not set validUntil' do
        expect(node['validUntil']).not_to be
      end
    end

    context 'Extensions' do
      it 'does not create mdrpi:PublisherInfo' do
        expect(xml).to have_xpath(all_publication_infos, count: 0)
      end
    end
  end
end
