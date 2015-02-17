require 'rails_helper'

RSpec.describe EntitySource do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence(:rank) }
  it { is_expected.to validate_integer(:rank) }
  it { is_expected.to validate_unique(:rank) }
  it { is_expected.to validate_presence(:active) }
end
