require 'rails_helper'

describe CaCertificate do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :data }
end
