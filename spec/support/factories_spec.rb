require 'rails_helper'

describe 'Factory Girl' do
  FactoryGirl.factories.map(&:name).each do |factory_name|
    describe "#{factory_name} factory" do

      it 'is valid' do
        factory = FactoryGirl.build(factory_name)
        if factory.respond_to?(:valid?)
          expect(factory).to be_valid,
                             -> { factory.errors.full_messages.join('\n') }
        end
      end

      traits = FactoryGirl.factories[factory_name].definition.defined_traits
      traits.map(&:name).each do |trait_name|
        context ":#{trait_name}" do
          it 'is valid' do
            factory = FactoryGirl.build(factory_name, trait_name)
            if factory.respond_to?(:valid?)
              expect(factory).to be_valid,
                                 -> { factory.errors.full_messages.join('\n') }
            end
          end
        end
      end

    end
  end
end
