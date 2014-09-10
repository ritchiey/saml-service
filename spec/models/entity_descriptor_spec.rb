require 'rails_helper'

describe EntityDescriptor do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :entities_descriptor }
  it { is_expected.to validate_presence :entity_id }
end
