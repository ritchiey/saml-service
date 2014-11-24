require 'rails_helper'

RSpec.describe MDUI::DisplayName, type: :model do
  it { is_expected.to have_many_to_one :ui_info }
  it { is_expected.to validate_presence :ui_info }
end
