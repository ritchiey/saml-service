require 'rails_helper'

RSpec.describe 'BasicFederation' do
  def run
    create :basic_federation
  end

  subject { run }

  it 'creates a single EntitiesDescriptor' do
    expect { run }.to change(EntitiesDescriptor, :count).by(1)
  end

  it 'creates five EntityDescriptors' do
    expect { run }.to change(EntityDescriptor, :count).by(5)
  end

  it 'creates two IDPSSODescriptors' do
    expect { run }.to change(IDPSSODescriptor, :count).by(2)
  end

  it 'creates three AttributeAuthorityDescriptors' do
    expect { run }.to change(AttributeAuthorityDescriptor, :count).by(3)
  end

  it 'creates two SPSSODescriptors' do
    expect { run }.to change(SPSSODescriptor, :count).by(2)
  end

  it { is_expected.to be_valid }

  context 'RoleDescriptors' do
    subject { run.entity_descriptors.flat_map(&:role_descriptors) }

    it 'has protocol supports' do
      subject.each { |rd| expect(rd.protocol_supports).not_to be_empty }
    end

    it 'provides cryptographic keys' do
      subject.each do |rd|
        rd.key_descriptors.each do |kd|
          expect(kd.key_info.data).not_to be_empty
        end
      end
    end
  end

  context 'IDPSSODescriptors' do
    subject { run.entity_descriptors.flat_map(&:idp_sso_descriptors) }

    it 'has single sign on service' do
      subject.each { |idp| expect(idp.single_sign_on_services).not_to be_empty }
    end
  end

  context 'SPSSODescriptors' do
    subject { run.entity_descriptors.flat_map(&:sp_sso_descriptors) }

    it 'has assertion consumer services' do
      subject.each do |sp|
        expect(sp.assertion_consumer_services).not_to be_empty
      end
    end
  end

  context 'AttributeAuthorityDescriptors' do
    subject do
      run.entity_descriptors.flat_map(&:attribute_authority_descriptors)
    end

    it 'has attribute_services' do
      subject.each { |aa| expect(aa.attribute_services).not_to be_empty }
    end
  end

  context 'REFEDS entity category' do
    subject do
      run.entity_descriptors.find_all { |ed| ed.sp_sso_descriptors.any? }
    end
    context 'Research and Scholarship' do
      it 'is created for each SPSSODescriptor' do
        expect(subject.size).to eq(2)
      end

      it 'specifies entity category attribute' do
        subject.each do |ed|
          ed.entity_attribute.attributes.each do |a|
            expect(a.name).to eq('http://macedir.org/entity-category')
          end
        end
      end

      it 'advertises research and scholarship support' do
        subject.each do |ed|
          ed.entity_attribute.attributes.each do |a|
            expect(a.attribute_values[0].value)
              .to eq('http://refeds.org/category/research-and-scholarship')
          end
        end
      end
    end
  end

  context 'eduGAIN metadata profile v3' do
    context 'PublicationInfo' do
      subject { run.publication_info }
      it { is_expected.to be_valid }
      it 'has a publisher' do
        expect(subject.publisher).not_to be nil
      end
    end

    context 'RegistrationInfo' do
      subject { run.entity_descriptors.map(&:registration_info) }

      it 'is created for each EntityDescriptor' do
        subject.each { |ri| expect(ri).to be_valid }
      end

      it 'has a registration authority' do
        subject.each { |ri| expect(ri.registration_authority).not_to be_nil }
      end

      it 'has a registration policy' do
        subject.each { |ri| expect(ri.registration_policies).not_to be_nil }
      end
    end

    context 'Organization' do
      subject { run.entity_descriptors.map(&:organization) }

      it 'is created for each EntityDescriptor' do
        subject.each { |o| expect(o).to be_valid }
      end

      it 'has organization name' do
        subject.each { |o| expect(o.organization_names).not_to be_nil }
      end

      it 'has organization display_name' do
        subject.each { |o| expect(o.organization_display_names).not_to be_nil }
      end

      it 'has organization urls' do
        subject.each { |o| expect(o.organization_urls).not_to be_nil }
      end
    end

    context 'ContactPerson' do
      subject { run.entity_descriptors.flat_map(&:contact_people) }

      it 'has contact_person' do
        subject.each { |cp| expect(cp.contact_type).to eq(:technical) }
      end

      it 'has email' do
        subject.each { |cp| expect(cp.contact.email_address).not_to be nil }
      end
    end

    context 'SPSSODescriptor' do
      subject { run.entity_descriptors.flat_map(&:sp_sso_descriptors) }

      context 'mdui' do
        it 'has mdui:display_name' do
          subject.each { |sp| expect(sp.ui_info.display_names).not_to be_empty }
        end
        it 'has mdui:description' do
          subject.each { |sp| expect(sp.ui_info.descriptions).not_to be_empty }
        end
      end

      context 'requested_attributes' do
        it 'has attribute_consuming_service' do
          subject.each do |sp|
            expect(sp.attribute_consuming_services).not_to be_empty
          end
        end

        it 'has requested_attributes' do
          subject.each do |sp|
            expect(sp.attribute_consuming_services[0].requested_attributes)
              .not_to be_empty
          end
        end
      end
    end
  end
end
