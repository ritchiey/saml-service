require 'rails_helper'

RSpec.describe Tag, type: :model do
  it_behaves_like 'a basic model'
  it { is_expected.to validate_presence :name }
end
