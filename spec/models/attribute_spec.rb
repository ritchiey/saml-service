require 'rails_helper'

describe Attribute do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :name }
  it { is_expected.to have_one_to_one :name_format }
  it { is_expected.to have_one_to_many :attribute_values }
  it { is_expected.to have_many_to_one :idp_sso_descriptor }

  context 'optional attributes' do
    it { is_expected.to have_column :friendly_name }
    it { is_expected.to have_column :legacy_name }
    it { is_expected.to have_column :oid }
    it { is_expected.to have_column :description }
  end
end
