require 'rails_helper'

RSpec.describe MDUI::UiInfo, type: :model do
  it_behaves_like 'a basic model'

  it { is_expected.to have_many_to_one :role_descriptor }
  it { is_expected.to validate_presence :role_descriptor }

  context 'optional attributes' do
    it { is_expected.to have_one_to_many :display_names }
    it { is_expected.to have_one_to_many :descriptions }
    it { is_expected.to have_one_to_many :keywords }
    it { is_expected.to have_one_to_many :logos }
    it { is_expected.to have_one_to_many :information_urls }
    it { is_expected.to have_one_to_many :privacy_statement_urls }
  end
end
