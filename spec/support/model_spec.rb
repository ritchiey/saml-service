shared_examples 'a basic model' do
  it { is_expected.to validate_presence :created_at }
  it { is_expected.to validate_presence :updated_at }
end

shared_examples 'an Endpoint' do
  it { is_expected.to be_an(Endpoint) }

  context 'provides no additional functionality' do
    it 'publicly' do
      expect(subject.public_methods(false).size).to eq 0
    end

    it 'privately' do
      expect(subject.private_methods(false).size).to eq 0
    end
  end
end

shared_examples 'an IndexedEndpoint' do
  it { is_expected.to be_an(IndexedEndpoint) }

  context 'provides no additional functionality' do
    it 'publicly' do
      expect(subject.public_methods(false).size).to eq 0
    end

    it 'privately' do
      expect(subject.private_methods(false).size).to eq 0
    end
  end
end
