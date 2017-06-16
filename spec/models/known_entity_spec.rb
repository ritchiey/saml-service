# frozen_string_literal: true

require 'rails_helper'

RSpec.describe KnownEntity do
  it_behaves_like 'a basic model'
  it_behaves_like 'a taggable model', :known_entity_tag, :known_entity

  it { is_expected.to validate_presence(:enabled) }
  it { is_expected.to validate_presence(:entity_source) }
  it { is_expected.to have_many_to_one(:entity_source) }
  it { is_expected.to have_one_to_one(:entity_descriptor) }
  it { is_expected.to have_one_to_one(:raw_entity_descriptor) }

  describe '#touch' do
    subject { create :known_entity }

    it 'modifies parent EntityDescriptor on save' do
      Timecop.travel(1.second) do
        expect { subject.touch }.to(change { subject.updated_at })
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

  describe '#tag_as' do
    let(:name) { Faker::Lorem.word }
    subject { create :known_entity }

    context 'tag already exists' do
      before { subject.add_tag(Tag.new(name: name)) }

      it 'does not increase tag count' do
        expect { subject.tag_as(name) }.not_to(change { subject.tags.length })
      end
    end

    context 'tag does not already exist' do
      it 'increases tag count' do
        expect { subject.tag_as(name) }.to(change { subject.tags.length })
      end

      it 'sets the tag to the provided name' do
        expect(subject.tags.any? { |t| t.name == name }).to be_falsey
        subject.tag_as(name)
        expect(subject.tags.any? { |t| t.name == name }).to be_truthy
      end
    end
  end

  describe '#untag_as' do
    let(:name) { Faker::Lorem.word }
    subject { create :known_entity }

    context 'tag already exists' do
      before { subject.add_tag(Tag.new(name: name)) }

      it 'decreases tag count' do
        expect { subject.untag_as(name) }.to(change { subject.tags.length })
      end

      it 'removes the tag with the provided name' do
        expect(subject.tags.any? { |t| t.name == name }).to be_truthy

        expect { subject.untag_as(name) }.to(
          change(Tag.where(name: name), :count)
            .by(-1)
            .and(change { subject.tags.map(&:name) }.to(not_include(name)))
        )
      end
    end

    context 'tag does not already exist' do
      it 'does not decrease tag count' do
        expect { subject.untag_as(name) }.not_to(change { subject.tags.length })
      end
    end
  end

  describe '::with_any_tag' do
    let!(:blacklisted_entity) { create(:known_entity) }
    let!(:allowed_entity) { create(:known_entity) }

    let!(:tags) do
      [
        create(:tag, name: 'aaf', known_entity: allowed_entity),
        create(:tag, name: 'aaf', known_entity: blacklisted_entity),
        create(:tag, name: 'blacklist', known_entity: blacklisted_entity)
      ]
    end

    it 'filters the blacklisted entity' do
      expect(KnownEntity.with_any_tag('aaf')).not_to include(blacklisted_entity)
    end

    it 'includes the allowed entity' do
      expect(KnownEntity.with_any_tag('aaf')).to include(allowed_entity)
    end

    context 'with `include_blacklisted: true`' do
      it 'includes the blacklisted entity' do
        expect(KnownEntity.with_any_tag('aaf', include_blacklisted: true))
          .to include(blacklisted_entity)
      end

      it 'includes the allowed entity' do
        expect(KnownEntity.with_any_tag('aaf', include_blacklisted: true))
          .to include(allowed_entity)
      end
    end
  end

  describe '::with_all_tags' do
    let!(:blacklisted_entity) { create(:known_entity) }
    let!(:allowed_entity) { create(:known_entity) }

    let!(:tags) do
      [
        create(:tag, name: 'aaf', known_entity: allowed_entity),
        create(:tag, name: 'aaf', known_entity: blacklisted_entity),
        create(:tag, name: 'blacklist', known_entity: blacklisted_entity)
      ]
    end

    it 'filters the blacklisted entity' do
      expect(KnownEntity.with_all_tags('aaf'))
        .not_to include(blacklisted_entity)
    end

    it 'includes the allowed entity' do
      expect(KnownEntity.with_all_tags('aaf')).to include(allowed_entity)
    end

    context 'with `include_blacklisted: true`' do
      it 'includes the blacklisted entity' do
        expect(KnownEntity.with_all_tags('aaf', include_blacklisted: true))
          .to include(blacklisted_entity)
      end

      it 'includes the allowed entity' do
        expect(KnownEntity.with_all_tags('aaf', include_blacklisted: true))
          .to include(allowed_entity)
      end
    end
  end
end
