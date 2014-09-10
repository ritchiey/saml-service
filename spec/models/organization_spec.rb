require 'rails_helper'

describe Organization do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :name }
  it { is_expected.to validate_presence :display_name }
  it { is_expected.to validate_presence :url }
  it { is_expected.to validate_presence :name }

  context 'optional attributes' do
    it { is_expected.to respond_to :extensions }
  end
end
