require 'rails_helper'

RSpec.describe KnownEntity do
  it_behaves_like 'a basic model'
  it_behaves_like 'a taggable model', :known_entity_tag, :known_entity

  it { is_expected.to validate_presence(:active) }
  it { is_expected.to validate_presence(:entity_source) }
  it { is_expected.to have_many_to_one(:entity_source) }
  it { is_expected.to have_one_to_one(:entity_descriptor) }
  it { is_expected.to have_one_to_one(:raw_entity_descriptor) }

  describe '#touch' do
    subject { create :known_entity }

    it 'modifies parent EntityDescriptor on save' do
      Timecop.travel(1.seconds) do
        expect { subject.touch }.to change { subject.updated_at }
      end
    end
  end

  describe '#destroy' do
    context 'with tags' do
      subject { create :known_entity }
      before { create_list :tag, 5, known_entity: subject }

      it 'is successfully destroyed' do
        expect { subject.destroy }.not_to raise_error
      end
    end

    context 'with entity_descriptor' do
      subject { create :known_entity, :with_idp }

      it 'is successfully destroyed' do
        expect { subject.destroy }.not_to raise_error
      end
    end

    context 'with raw_entity_descriptor' do
      subject { create :known_entity, :with_raw_entity_descriptor }

      it 'is successfully destroyed' do
        expect { subject.destroy }.not_to raise_error
      end
    end
  end
end
