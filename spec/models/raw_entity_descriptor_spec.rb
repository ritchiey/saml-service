require 'rails_helper'

RSpec.describe RawEntityDescriptor do
  it_behaves_like 'a basic model'

  it { is_expected.to have_many_to_one(:known_entity) }

  it { is_expected.to validate_presence(:xml) }
  it { is_expected.to validate_max_length(65_535, :xml) }
  it { is_expected.to validate_presence(:known_entity) }
  it { is_expected.to validate_unique(:known_entity) }
end
