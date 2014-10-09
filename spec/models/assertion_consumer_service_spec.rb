require 'rails_helper'

describe AssertionConsumerService do
  it_behaves_like 'an IndexedEndpoint'
  it { is_expected.to have_many_to_one :sp_sso_descriptor }
end
