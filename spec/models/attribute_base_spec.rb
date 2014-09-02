require 'rails_helper'

describe AttributeBase do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :name }
  it { is_expected.to validate_presence :legacy_name }
  it { is_expected.to validate_presence :oid }
  it { is_expected.to validate_presence :description }
  it { is_expected.to validate_presence :name_format }
  it { is_expected.to have_many_to_one :name_format }
end
