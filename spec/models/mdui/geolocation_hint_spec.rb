require 'rails_helper'

RSpec.describe MDUI::GeolocationHint, type: :model do
  it_behaves_like 'a basic model'

  it { is_expected.to have_many_to_one :disco_hints }
  it { is_expected.to validate_presence :disco_hints }
  it { is_expected.to validate_presence :uri }
end
