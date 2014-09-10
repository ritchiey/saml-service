require 'rails_helper'

describe KeyDescriptor do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :key_type_id }
  it { is_expected.to validate_presence :key_type }
  it { is_expected.to validate_includes [:encryption, :signing], :key_type }

  it { is_expected.to validate_presence :key_info }
end
