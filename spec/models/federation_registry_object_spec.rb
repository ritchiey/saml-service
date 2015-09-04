require 'rails_helper'

RSpec.describe FederationRegistryObject do
  describe '::local_model' do
    let!(:idp) { create :idp_sso_descriptor }
    let(:fr_id) { rand(10..200) }
    let!(:fr_obj) do
      FederationRegistryObject.create(fr_id: fr_id,
                                      internal_class_name: idp.class.name,
                                      internal_id: idp.id)
    end

    context 'valid input' do
      let(:instance) do
        FederationRegistryObject.local_instance(fr_id, idp.class.name)
      end
      it 'supplies expected instance' do
        expect(instance).to eq(idp)
      end
    end

    context 'invalid input' do
      context 'FR ID not locally stored' do
        let(:instance) do
          FederationRegistryObject.local_instance(fr_id + 1, idp.class.name)
        end
        it 'fails' do
          expect(instance).to be_nil
        end
      end

      context 'FR ID not locally stored' do
        let(:class_name) { Faker::Lorem.word }
        let(:instance) do
          FederationRegistryObject.local_instance(fr_id, class_name)
        end
        it 'fails' do
          expect(instance).to be_nil
        end
      end
    end
  end
end
