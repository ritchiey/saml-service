require 'rails_helper'

RSpec.describe MDUI::UiInfo, type: :model do
  it { is_expected.to have_many_to_one :role_descriptor }
  it { is_expected.to validate_presence :role_descriptor }

  context 'optional attributes' do
    it { is_expected.to have_one_to_one :display_name }
  end
end
