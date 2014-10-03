require 'rails_helper'

describe SamlURI do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :uri }
end
