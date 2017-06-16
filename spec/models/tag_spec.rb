# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag, type: :model do
  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence :name }
  it { is_expected.to have_many_to_one :known_entity }

  let(:role_descriptor) { create(:role_descriptor) }
  let(:known_entity) { create(:known_entity) }

  let(:tag_name) { Faker::Lorem.word }

  context 'with no owner' do
    let(:tag) { build(:tag, known_entity: nil) }
    subject { tag }
    it { is_expected.to_not be_valid }
    context 'the error message' do
      before { tag.valid? }
      subject { tag.errors }
      it 'is expected to be a single owner validation' do
        expect(subject).to eq(known_entity: ['is not present'])
      end
    end
  end

  context '[name, known_entity] uniqueness' do
    before do
      create(:known_entity_tag,
             known_entity: known_entity, name: tag_name)
    end

    let(:tag) do
      build(:known_entity_tag,
            known_entity: known_entity, name: tag_name)
    end

    subject { tag }
    before { tag.valid? }
    it { is_expected.to_not be_valid }

    context 'the error message' do
      subject { tag.errors }
      it 'is expected to be a uniqueness validation' do
        expect(subject)
          .to eq(%i[name known_entity] => ['is already taken'])
      end
    end
  end

  describe '#name' do
    let(:tag) { build(:tag, name: tag_name) }
    before { tag.valid? }
    subject { tag }

    context 'using url-safe base64 alphabet' do
      let(:tag_name) { SecureRandom.urlsafe_base64 }
      it { is_expected.to be_valid }
    end

    context 'not using url-safe base64 alphabet' do
      let(:tag_name) { '@*!' }
      it { is_expected.to_not be_valid }

      context 'the errors' do
        subject { tag.errors }
        it { is_expected.to eq(name: ['is not in base64 urlsafe alphabet']) }
      end
    end
  end

  describe '::update_derived_tags' do
    let(:tags) { Faker::Lorem.words(10).uniq }
    let(:derived_tag) { Faker::Lorem.words.join('-') }
    let(:negative_tags) { Faker::Lorem.words(100).uniq - tags }

    let(:config) { { metadata: { derived_tags: derived_tags_config } } }

    let(:derived_tags_config) do
      [{ tag: derived_tag, when: tags, unless: negative_tags }]
    end

    let(:known_entity) { create(:known_entity) }

    before do
      allow(Rails)
        .to receive_message_chain(:application, :config, :saml_service)
        .and_return(RecursiveOpenStruct.new(config))
    end

    def run
      Tag.update_derived_tags(known_entity)
    end

    def tag_names
      Tag.where(known_entity_id: known_entity.id).all.map(&:name)
    end

    context 'when the tags are present' do
      before { tags.each { |tag| known_entity.tag_as(tag) } }

      context 'with derived tag already present' do
        before { known_entity.tag_as(derived_tag) }

        it 'changes nothing' do
          expect { run }.not_to change { tag_names }
        end
      end

      context 'without the derived tag' do
        it 'adds the derived tag' do
          expect { run }.to change { tag_names }.to include(derived_tag)
        end
      end

      context 'when a negative tag is present' do
        before { known_entity.tag_as(negative_tags.sample) }

        context 'with derived tag already present' do
          before { known_entity.tag_as(derived_tag) }

          it 'removes the derived tag' do
            expect { run }.to change { tag_names }.to not_include(derived_tag)
          end
        end

        context 'without the derived tag' do
          it 'changes nothing' do
            expect { run }.not_to change { tag_names }
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
        before { known_entity.tag_as(derived_tag) }

        it 'removes the derived tag' do
          expect { run }.to change { tag_names }.to not_include(derived_tag)
        end
      end

      context 'without the derived tag' do
        it 'changes nothing' do
          expect { run }.not_to change { tag_names }
        end
      end
    end
  end
end
