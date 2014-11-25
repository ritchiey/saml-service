require 'rails_helper'

RSpec.describe MDUI::Logo, type: :model do
  context 'Extends LocalizedURI' do
    it { is_expected.to have_many_to_one :ui_info }
    it { is_expected.to validate_presence :ui_info }

    describe '#width' do
      subject { create :mdui_logo }
      it 'rejects negative integers' do
        subject.width = -1
        expect(subject).not_to be_valid
      end
      it 'rejects zero integers' do
        subject.width = 0
        expect(subject).not_to be_valid
      end
      it 'rejects nil integers' do
        subject.width = nil
        expect(subject).not_to be_valid
      end
      it 'accepts positive integers' do
        subject.width = 100
        expect(subject).to be_valid
      end
    end

    describe '#height' do
      subject { create :mdui_logo }
      it 'rejects negative integers' do
        subject.height = -1
        expect(subject).not_to be_valid
      end
      it 'rejects zero integers' do
        subject.height = 0
        expect(subject).not_to be_valid
      end
      it 'rejects nil integers' do
        subject.height = nil
        expect(subject).not_to be_valid
      end
      it 'accepts positive integers' do
        subject.height = 100
        expect(subject).to be_valid
      end
    end
  end
end
