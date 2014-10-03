require 'rails_helper'

RSpec.describe NameIdFormat, type: :model do
  context 'Extends SamlURI' do
    it { is_expected.to have_many_to_one :sso_descriptor }
    it { is_expected.to validate_presence :sso_descriptor, allow_missing: false } # rubocop:disable Metrics/LineLength
  end
end
