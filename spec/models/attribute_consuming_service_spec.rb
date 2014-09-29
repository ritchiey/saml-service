require 'rails_helper'

describe AttributeConsumingService do
  it_behaves_like 'a basic model'

  it { is_expected.to have_one_to_many :service_descriptions }
  it { is_expected.to validate_presence :index, allow_missing: false }
  it { is_expected.to validate_presence :default, allow_missing: false }
  it 'should validate presence of :sp_sso_descriptor with
      option(s) :allow_missing => false' do
    expect(subject).to validate_presence :sp_sso_descriptor,
                                         allow_missing: false
  end

  let(:subject) { FactoryGirl.create :attribute_consuming_service }
  it 'has at least 1 service name' do
    expect(subject).to validate_presence :service_names,
                                         allow_missing: false
  end
  it 'has at least 1 requested attribute' do
    expect(subject).to validate_presence :requested_attributes,
                                         allow_missing: false
  end
end
