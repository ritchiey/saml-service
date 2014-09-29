require 'rails_helper'

describe LocalizedURI do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :value }
  it { is_expected.to validate_presence :lang }

  context 'value' do
    it 'rejects invalid URL' do
      subject.lang = 'en'
      subject.value = 'invalid'
      expect(subject.valid?).to be false
    end

    context 'valid URL formats' do
      it 'http' do
        subject.lang = 'en'
        subject.value = 'http://example.org'
        expect(subject.valid?).to be true
      end

      it 'https' do
        subject.lang = 'en'
        subject.value = 'https://example.org'
        expect(subject.valid?).to be true
      end

      it 'with port number' do
        subject.lang = 'en'
        subject.value = 'https://example.org:8080'
        expect(subject.valid?).to be true
      end
    end
  end

end
