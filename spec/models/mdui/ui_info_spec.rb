require 'rails_helper'

RSpec.describe MDUI::UiInfo, type: :model do
  it { is_expected.to have_many_to_one :entity_descriptor }
  it { is_expected.to validate_presence :role_descriptor }
end
