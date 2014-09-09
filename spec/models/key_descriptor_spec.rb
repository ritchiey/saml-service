require 'rails_helper'

describe KeyDescriptor do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :key_type }
  it { is_expected.to validate_presence :key_info }
end
