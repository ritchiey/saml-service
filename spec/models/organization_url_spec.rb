require 'rails_helper'

describe OrganizationURL do
  context 'Extends LocalizedName' do
    it { is_expected.to validate_presence :organization }
  end
end
