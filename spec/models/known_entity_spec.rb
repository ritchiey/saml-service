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

  describe '#update_derived_tags' do
    before { DerivedTag.all.each(&:destroy) }

    let(:tags) { Faker::Lorem.words(10).uniq }
    let(:derived_tag_name) { Faker::Lorem.words.join('-') }
    let(:negative_tags) { (Faker::Lorem.words(100).uniq - tags).take(10) }
    let(:known_entity) { create(:known_entity) }

    let!(:derived_tag) do
      create(:derived_tag,
             tag_name: derived_tag_name,
             when_tags: tags.join(','),
             unless_tags: negative_tags.join(','))
    end

    def run
      known_entity.update_derived_tags
    end

    def tag_names
      Tag.where(known_entity_id: known_entity.id).all.map(&:name)
    end

    def create_derived_tag
      known_entity.add_tag(name: derived_tag_name, derived: true)
    end

    context 'when the tags are present' do
      before { tags.each { |tag| known_entity.tag_as(tag) } }

      context 'with derived tag already present' do
        before { create_derived_tag }

        it 'changes nothing' do
          expect { run }.not_to(change { tag_names })
        end
      end

      context 'without the derived tag' do
        it 'adds the derived tag' do
          expect { run }.to change { tag_names }.to include(derived_tag_name)
          expect(known_entity.tags.last).to have_attributes(derived: true)
        end

        context 'when one of the condition tags is derived' do
          before do
            tag_name = tags.sample
            known_entity.untag_as(tag_name)
            known_entity.add_tag(name: tag_name, derived: true)
            known_entity.reload
          end

          it 'changes nothing' do
            expect { run }.not_to(change { tag_names })
          end
        end
      end

      context 'when a negative tag is present' do
        before { known_entity.tag_as(negative_tags.sample) }

        context 'with derived tag already present' do
          before { create_derived_tag }

          it 'removes the derived tag' do
            expect { run }.to change { tag_names }
              .to not_include(derived_tag_name)
          end
        end

        context 'without the derived tag' do
          it 'changes nothing' do
            expect { run }.not_to(change { tag_names })
          end
        end
      end
    end

    context 'when a tag is not present' do
      before do
        tags.each { |tag| known_entity.tag_as(tag) }
        known_entity.untag_as(tags.sample)
      end

      context 'with derived tag already present' do
        before { create_derived_tag }

        it 'removes the derived tag' do
          expect { run }.to change { tag_names }
            .to not_include(derived_tag_name)
        end
      end

      context 'with the derived tag manually applied' do
        before { known_entity.tag_as(derived_tag_name) }

        it 'changes nothing' do
          expect { run }.not_to(change { tag_names })
        end
      end

      context 'without the derived tag' do
        it 'changes nothing' do
          expect { run }.not_to(change { tag_names })
        end
      end
    end
  end
end
