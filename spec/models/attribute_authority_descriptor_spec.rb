require 'rails_helper'

RSpec.describe AttributeAuthorityDescriptor, type: :model do
  it { is_expected.to validate_presence :entity_descriptor }
  it { is_expected.to have_many_to_one :entity_descriptor }

  context 'Extends RoleDescriptor' do
    it { is_expected.to have_one_to_many :attribute_services }
    it { is_expected.to have_one_to_many :assertion_id_request_services }
    it { is_expected.to have_one_to_many :name_id_formats }
    it { is_expected.to have_one_to_many :attribute_profiles }
    it { is_expected.to have_one_to_many :attributes }
  end
end
