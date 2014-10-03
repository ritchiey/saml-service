require 'rails_helper'

RSpec.describe AttributeProfile, type: :model do
  context 'Extends SamlURI' do
    it { is_expected.to have_many_to_one :idp_sso_descriptor }
  end
end
