require 'rails_helper'

describe IndexedEndpoint do
  context 'extends an Endpoint' do
    it { is_expected.to validate_presence :is_default }
    it { is_expected.to validate_presence :index }
  end
end
