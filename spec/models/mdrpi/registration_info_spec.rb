require 'rails_helper'

RSpec.describe MDRPI::RegistrationInfo, type: :model do
  it_behaves_like 'a basic model'

  it { is_expected.to have_many_to_one :entities_descriptor }
  it { is_expected.to have_many_to_one :entity_descriptor }

  it { is_expected.to validate_presence :registration_authority }

  context 'optional attributes' do
    it { is_expected.to respond_to :registration_instant }
  end

  context 'instance validations' do
    let(:subject) { create :mdrpi_registration_info }

    it { is_expected.to validate_presence :registration_policies }

    context 'ownership' do
      it 'must be owned' do
        expect(subject).not_to be_valid
      end

      it 'owned by entities_descriptor' do
        subject.entities_descriptor = create :entities_descriptor
        expect(subject).to be_valid
      end

      it 'owned by entity_descriptor' do
        subject.entity_descriptor = create :entity_descriptor
        expect(subject).to be_valid
      end

      it 'cant have multiple owners' do
        subject.entities_descriptor = create :entities_descriptor
        subject.entity_descriptor = create :entity_descriptor

        expect(subject).not_to be_valid
      end
    end
  end

  context '#registration_instant_utc' do
    let(:subject) { create :mdrpi_registration_info }

    around { |example| Timecop.freeze { example.run } }

    it 'uses created_at if registration_instant not explicitly set' do
      expect(subject.registration_instant_utc).to eq(subject.created_at.utc)
    end
    it 'uses registration_instant if set' do
      subject.registration_instant = Time.now - 2.months
      expect(subject.registration_instant_utc)
        .to eq(subject.registration_instant.utc)
    end
  end
end
