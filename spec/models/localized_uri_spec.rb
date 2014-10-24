require 'rails_helper'

describe LocalizedURI do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :value }
  it { is_expected.to validate_presence :lang }

  context 'value' do
    it 'rejects invalid URL' do
      subject.lang = 'en'
      subject.value = 'invalid'
      expect(subject).not_to be_valid
    end

    context 'valid URL formats' do
      it 'http' do
        subject.lang = 'en'
        subject.value = 'http://example.org'
        expect(subject).to be_valid
      end

      it 'https' do
        subject.lang = 'en'
        subject.value = 'https://example.org'
        expect(subject).to be_valid
      end

      it 'with port number' do
        subject.lang = 'en'
        subject.value = 'https://example.org:8080'
        expect(subject).to be_valid
      end
    end
  end

end
