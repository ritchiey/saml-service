require 'rails_helper'

describe KeyDescriptor do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :key_type }
  it { is_expected.to validate_presence :key_info }

  context '#type' do
    it 'is delegated to key_type#use' do
      subject = FactoryGirl.create :key_descriptor
      expect(subject.type).to eq subject.key_type.use
    end
  end
end
