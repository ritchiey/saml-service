require 'rails_helper'

describe KeyDescriptor do
  it_behaves_like 'a basic model'

  context 'validations' do
    context 'instance validations' do
      let(:subject) { create :key_descriptor, :signing }
      it { is_expected.to validate_presence :key_info }
      it { is_expected.to validate_includes [:encryption, :signing], :key_type }
    end
  end
end
