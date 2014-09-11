require 'rails_helper'

describe Organization do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :name }
  it { is_expected.to validate_presence :display_name }
  it { is_expected.to validate_presence :url }
  it { is_expected.to validate_presence :name }
end
