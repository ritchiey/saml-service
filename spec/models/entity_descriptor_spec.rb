require 'rails_helper'

describe EntityDescriptor do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :entities_descriptor }
  it { is_expected.to validate_presence :entity_id }

  context 'optional attributes' do
    it { is_expected.to respond_to :organization }
    it { is_expected.to respond_to :contact_people }
    it { is_expected.to respond_to :additional_metadata_locations }

    it { is_expected.to respond_to :extensions }
  end

end
