require 'rails_helper'

describe EntitiesDescriptor do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :identifier }
  it { is_expected.to validate_presence :name }

  context 'optional attributes' do
    it { is_expected.to respond_to :extensions }
  end
end
