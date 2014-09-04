require 'rails_helper'

describe Attribute do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :attribute_base }
  it { is_expected.to have_many_to_one :attribute_base }
  it { is_expected.to have_one_to_many :attribute_values }
end
