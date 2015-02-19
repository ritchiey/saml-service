shared_examples 'a taggable model' do | tag_factory, association |
  let(:klass) { described_class.name.underscore.to_sym }

  def factory_args(tag_name, instance, association)
    factory_args = {}
    factory_args[:name] = tag_name
    factory_args[association] = instance
    factory_args
  end

  describe '#with_any_tag' do
    let(:tag_name) { Faker::Lorem.word }
    let(:instance) { create(klass) }

    subject { described_class.with_any_tag(tag_name) }

    context 'when no tags exist' do
      it { is_expected.to eq([]) }
    end

    context 'when an associated tag exists' do
      before do
        create(tag_factory,
               factory_args(tag_name, instance, association))
      end
      it { is_expected.to contain_exactly(instance) }
      it { is_expected.to contain_exactly(an_instance_of(described_class)) }
    end

    context "when a tag exists for multiple #{described_class.name}" do
      let!(:another_instance) { create(klass) }

      before do
        create(tag_factory, factory_args(tag_name, instance, association))
        create(tag_factory, factory_args(tag_name,
                                         another_instance, association))
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
        create(tag_factory, factory_args(tag_name, instance, association))
        create(tag_factory, factory_args(another_tag_name, instance,
                                         association))
      end

      it { is_expected.to contain_exactly(instance) }
      it { is_expected.to contain_exactly(an_instance_of(described_class)) }
    end

    context "with a tag exists amongst many #{described_class.name}" do
      let(:another_tag_name) { Faker::Lorem.word }
      let!(:another_instance) { create(klass) }

      subject { described_class.with_any_tag(tag_name) }

      before do
        create(tag_factory, factory_args(tag_name, instance, association))
        create(tag_factory, factory_args(another_tag_name, another_instance,
                                         association))
      end

      it { is_expected.to contain_exactly(instance) }
      it { is_expected.to contain_exactly(an_instance_of(described_class)) }
    end
  end
end
