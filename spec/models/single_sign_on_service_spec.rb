require 'rails_helper'

describe SingleSignOnService do
  it_behaves_like 'an Endpoint'
  it { is_expected.to have_many_to_one :idp_sso_descriptor }
end
