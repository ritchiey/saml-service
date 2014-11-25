require 'rails_helper'

RSpec.describe MDUI::DiscoHints, type: :model do
  it_behaves_like 'a basic model'

  context 'optional attributes' do
    it { is_expected.to have_one_to_many :ip_hints }
    it { is_expected.to have_one_to_many :domain_hints }
  end
end
