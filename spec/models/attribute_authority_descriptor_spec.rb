require 'rails_helper'

RSpec.describe AttributeAuthorityDescriptor, type: :model do
  it_behaves_like 'a taggable model', :role_descriptor_tag, :role_descriptor

  context 'Extends RoleDescriptor' do
    it { is_expected.to have_one_to_many :attribute_services }
    it { is_expected.to have_one_to_many :assertion_id_request_services }
    it { is_expected.to have_one_to_many :name_id_formats }
    it { is_expected.to have_one_to_many :attribute_profiles }
    it { is_expected.to have_one_to_many :attributes }

    context 'validations' do
      context 'instance validations' do
        it { is_expected.to validate_presence :attribute_services }
      end
    end

    describe '#assertion_id_request_services?' do
      context 'when populated' do
        subject do
          create(:attribute_authority_descriptor,
                 :with_multiple_assertion_id_request_services)
        end
        it 'is true' do
          expect(subject.assertion_id_request_services?).to be
        end
      end
      context 'when unpopulated' do
        subject { create :attribute_authority_descriptor }
        it 'is false' do
          expect(subject.assertion_id_request_services?).not_to be
        end
      end
    end

    describe '#name_id_formats?' do
      context 'when populated' do
        subject do
          create(:attribute_authority_descriptor,
                 :with_multiple_name_id_formats)
        end
        it 'is true' do
          expect(subject.name_id_formats?).to be
        end
      end
      context 'when unpopulated' do
        subject { create :attribute_authority_descriptor }
        it 'is false' do
          expect(subject.name_id_formats?).not_to be
        end
      end
    end

    describe '#attribute_profiles?' do
      context 'when populated' do
        subject do
          create(:attribute_authority_descriptor,
                 :with_multiple_attribute_profiles)
        end
        it 'is true' do
          expect(subject.attribute_profiles?).to be
        end
      end
      context 'when unpopulated' do
        subject { create :attribute_authority_descriptor }
        it 'is false' do
          expect(subject.attribute_profiles?).not_to be
        end
      end
    end

    describe '#attributes?' do
      context 'when populated' do
        subject do
          create(:attribute_authority_descriptor,
                 :with_multiple_attributes)
        end
        it 'is true' do
          expect(subject.attributes?).to be
        end
      end
      context 'when unpopulated' do
        subject { create :attribute_authority_descriptor }
        it 'is false' do
          expect(subject.attributes?).not_to be
        end
      end
    end
  end
end
