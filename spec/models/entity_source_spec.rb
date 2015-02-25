require 'rails_helper'

RSpec.describe EntitySource do
  subject { build(:entity_source) }

  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence(:rank) }
  it { is_expected.to validate_integer(:rank) }
  it { is_expected.to validate_unique(:rank) }
  it { is_expected.to validate_presence(:active) }
  it { is_expected.to validate_presence(:url) }

  context 'url validation' do
    it 'accepts a valid https url' do
      subject.url = 'https://fed.example.com/metadata/full.xml'
      expect(subject).to be_valid
    end

    it 'accepts a valid http url' do
      subject.url = 'http://fed.example.com/metadata/full.xml'
      expect(subject).to be_valid
    end

    it 'rejects an ftp url' do
      subject.url = 'ftp://fed.example.com/metadata/full.xml'
      expect(subject).not_to be_valid
    end

    it 'rejects a url which does not parse' do
      subject.url = 'https://fed.test_example.com/metadata/full.xml'
      expect(subject).not_to be_valid
    end
  end
end
