require 'rails_helper'

describe EncryptionMethod do
  it_behaves_like 'a basic model'
  it { is_expected.to validate_presence :algorithm }
end
