require 'rails_helper'

describe EntityDescriptor do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :entities_descriptor }
  it { is_expected.to validate_presence :entity_id }

  context 'optional attributes' do
    it { is_expected.to have_many_to_one :organization }
    it { is_expected.to have_one_to_many :contact_people }
    it { is_expected.to have_one_to_many :additional_metadata_locations }
    it { is_expected.to have_column :extensions, type: :text }
  end

end
