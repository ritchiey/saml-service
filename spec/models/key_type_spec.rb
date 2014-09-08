require 'rails_helper'

describe KeyType do
  it_behaves_like 'a basic model'
  it { is_expected.to validate_presence :use }
  it { is_expected.to validate_includes [:encryption, :signing], :use }
end
