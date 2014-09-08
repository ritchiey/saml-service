require 'rails_helper'

describe KeyInfo do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :data }
  it { is_expected.to respond_to :key_name }
  it { is_expected.to respond_to :subject }
  it { is_expected.to respond_to :issuer }
  it { is_expected.to respond_to :expiry }
end
