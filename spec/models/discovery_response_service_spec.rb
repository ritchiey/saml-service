require 'rails_helper'

describe DiscoveryResponseService do
  it { is_expected.to have_many_to_one :sp_sso_descriptor }
end
