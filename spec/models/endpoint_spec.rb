describe Endpoint do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :location }

  context 'location' do
    it 'rejects invalid URL' do
      subject.location = 'invalid'
      expect(subject.valid?).to be false
    end

    context 'valid URL formats' do
      it 'http' do
        subject.location = 'http://example.org'
        expect(subject.valid?).to be true
      end

      it 'https' do
        subject.location = 'https://example.org'
        expect(subject.valid?).to be true
      end

      it 'with port number' do
        subject.location = 'https://example.org:8080'
        expect(subject.valid?).to be true
      end
    end
  end

  context 'response_location' do
    subject { FactoryGirl.create(:_endpoint) }

    it 'rejects invalid URL' do
      subject.response_location = 'invalid'
      expect(subject.valid?).to be false
    end

    context 'valid URL formats' do
      it 'http' do
        subject.response_location = 'http://example.org'
        expect(subject.valid?).to be true
      end

      it 'https' do
        subject.response_location = 'https://example.org'
        expect(subject.valid?).to be true
      end

      it 'with port number' do
        subject.response_location = 'https://example.org:8080'
        expect(subject.valid?).to be true
      end
    end
  end
end
