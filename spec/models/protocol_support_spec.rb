require 'rails_helper'

RSpec.describe ProtocolSupport, type: :model do
  context 'Extends SamlURI' do
    it { is_expected.to have_many_to_one :role_descriptor }
    it { is_expected.to validate_presence :role_descriptor }
  end
end
