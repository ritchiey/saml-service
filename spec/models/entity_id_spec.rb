require 'rails_helper'

RSpec.describe EntityId, type: :model do
  context 'extends saml uri' do
    it { is_expected.to have_many_to_one :entity_descriptor }
    it { is_expected.to validate_presence :entity_descriptor }
    it { is_expected.to validate_max_length 1024, :uri }
  end
end
