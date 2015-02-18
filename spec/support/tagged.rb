shared_examples 'a tagged model' do
  let(:klass) { described_class.name.underscore.to_sym }

  describe '#with_any_tag' do
    let(:tag_name) { Faker::Lorem.word }
    let(:instance) { create(klass) }

    subject { described_class.with_any_tag(tag_name) }

    context 'when no tags exist' do
      it { is_expected.to eq([]) }
    end

    context 'when an associated tag exists' do
      before do
        create(:role_descriptor_tag, role_descriptor: instance,
                                     name: tag_name)
      end
      it { is_expected.to contain_exactly(instance) }
      it { is_expected.to contain_exactly(an_instance_of(described_class)) }
    end

    context "when a tag exists for multiple #{described_class.name}" do
      let!(:another_instance) { create(klass) }

      before do
        create(:role_descriptor_tag, role_descriptor: instance,
                                     name: tag_name)
        create(:role_descriptor_tag, role_descriptor: another_instance,
                                     name: tag_name)
      end
      it do
        is_expected.to contain_exactly(instance, another_instance)
      end
      it do
        is_expected.to contain_exactly(an_instance_of(described_class),
                                       an_instance_of(described_class))
      end
    end

    context "with multiple tags existing for a #{described_class.name}" do
      let(:another_tag_name) { Faker::Lorem.word }

      subject { described_class.with_any_tag([tag_name, another_tag_name]) }

      before do
        create(:role_descriptor_tag, role_descriptor: instance,
                                     name: tag_name)
        create(:role_descriptor_tag, role_descriptor: instance,
                                     name: another_tag_name)
      end

      it { is_expected.to contain_exactly(instance) }
      it { is_expected.to contain_exactly(an_instance_of(described_class)) }
    end

    context 'with multiple unrelated tags already existing' do
      let(:another_tag_name) { Faker::Lorem.word }
      let(:role_descriptor) { create(:role_descriptor) }

      subject { described_class.with_any_tag([tag_name, another_tag_name]) }

      before do
        create(:role_descriptor_tag, name: tag_name)
        create(:role_descriptor_tag, name: another_tag_name)
      end

      it { is_expected.to eq([]) }
    end
  end
end
