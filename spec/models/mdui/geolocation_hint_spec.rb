require 'rails_helper'

RSpec.describe MDUI::GeolocationHint, type: :model do
  it_behaves_like 'a basic model'

  it { is_expected.to have_many_to_one :disco_hints }
  it { is_expected.to validate_presence :disco_hints }
  it { is_expected.to validate_presence :uri }

  context 'destructuring the geo uri' do
    let(:latitude) { Faker::Address.latitude }
    let(:longitude) { Faker::Address.longitude }
    let(:altitude) { Faker::Number.number(3) }

    subject do
      parts = [latitude, longitude, altitude].compact
      build(:mdui_geolocation_hint, uri: "geo:#{parts.join(',')}")
    end

    describe '#latitude' do
      it 'returns the latitude portion of the uri' do
        expect(subject.latitude).to eq(latitude)
      end
    end

    describe '#longitude' do
      it 'returns the longitude portion of the uri' do
        expect(subject.longitude).to eq(longitude)
      end
    end

    describe '#altitude' do
      it 'returns the altitude portion of the uri' do
        expect(subject.altitude).to eq(altitude)
      end

      context 'for a 2-part geo URI' do
        let(:altitude) { nil }

        it 'returns nil for altitude' do
          expect(subject.altitude).to be_nil
        end
      end
    end
  end
end
