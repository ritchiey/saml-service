require 'rails_helper'

describe RoleDescriptor do
  it_behaves_like 'a basic model'

  it { is_expected.to have_many_to_one :entity_descriptor }
  it { is_expected.to validate_presence :error_url }
  it { is_expected.to validate_presence :active }

  context 'optional attributes' do
    it { is_expected.to have_many_to_one :organization }
    it { is_expected.to have_one_to_many :key_descriptors }
    it { is_expected.to have_one_to_many :contact_people }
    it { is_expected.to have_column :extensions, type: :text }
  end
end
