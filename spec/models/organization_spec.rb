require 'rails_helper'

describe Organization do
  it_behaves_like 'a basic model'

  it { is_expected.to have_one_to_many :organization_names }

  let(:subject) { create Organization }
  it 'has at least 1 organization_name' do
    expect(subject).to validate_presence :organization_names,
                                         allow_missing: false
  end
  it 'has at least 1 organization_display_name' do
    expect(subject).to validate_presence :organization_display_names,
                                         allow_missing: false
  end
  it 'has at least 1 organization_url' do
    expect(subject).to validate_presence :organization_urls,
                                         allow_missing: false
  end
end
