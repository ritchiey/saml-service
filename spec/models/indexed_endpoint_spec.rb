require 'rails_helper'

describe IndexedEndpoint do
  it { is_expected.to validate_presence :is_default }
  it { is_expected.to validate_presence :index }
end
