require 'rails_helper'

RSpec.describe KnownEntity do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence(:active) }
  it { is_expected.to validate_presence(:entity_source) }
  it { is_expected.to have_many_to_one(:entity_source) }
  it { is_expected.to have_one_to_one(:entity_descriptor) }
  it { is_expected.to have_one_to_one(:raw_entity_descriptor) }
end
