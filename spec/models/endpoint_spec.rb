describe Endpoint do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :location }

  context 'location' do
    it 'rejects invalid URL' do
      subject.location = 'invalid'
      expect(subject).not_to be_valid
    end

    context 'valid URL formats' do
      it 'http' do
        subject.location = 'http://example.org'
        expect(subject).to be_valid
      end

      it 'https' do
        subject.location = 'https://example.org'
        expect(subject).to be_valid
      end

      it 'with port number' do
        subject.location = 'https://example.org:8080'
        expect(subject).to be_valid
      end
    end
  end

  context 'response_location' do
    subject { create(:_endpoint) }

    it 'rejects invalid URL' do
      subject.response_location = 'invalid'
      expect(subject).not_to be_valid
    end

    context 'valid URL formats' do
      it 'http' do
        subject.response_location = 'http://example.org'
        expect(subject).to be_valid
      end

      it 'https' do
        subject.response_location = 'https://example.org'
        expect(subject).to be_valid
      end

      it 'with port number' do
        subject.response_location = 'https://example.org:8080'
        expect(subject).to be_valid
      end
    end
  end
end
