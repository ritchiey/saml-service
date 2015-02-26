RSpec.shared_examples 'SPSSODescriptor xml' do
  let(:assertion_consumer_service_path) do
    "#{sp_sso_descriptor_path}/AssertionConsumerService"
  end

  let(:attribute_consuming_service_path) do
    "#{sp_sso_descriptor_path}/AttributeConsumingService"
  end

  let(:idpdisc_discovery_response_path) do
    "#{sp_sso_descriptor_path}/Extensions/idpdisc:DiscoveryResponse"
  end

  it 'is created' do
    expect(xml).to have_xpath(sp_sso_descriptor_path)
  end

  context 'attributes' do
    let(:node) { xml.first(:xpath, sp_sso_descriptor_path) }

    context 'AuthnRequestsSigned' do
      it 'is rendered' do
        expect(node['AuthnRequestsSigned']).to be
      end
      context 'when explicitly set' do
        let(:sp_sso_descriptor) do
          create :sp_sso_descriptor, :with_authn_requests_signed
        end
        it 'is rendered' do
          expect(node['AuthnRequestsSigned'])
            .to eq(sp_sso_descriptor.authn_requests_signed.to_s)
        end
      end
    end

    context 'WantAssertionsSigned' do
      it 'is rendered' do
        expect(node['WantAssertionsSigned']).to be
      end
      context 'when explicitly set' do
        let(:sp_sso_descriptor) do
          create :sp_sso_descriptor, :with_want_assertions_signed
        end
        it 'is rendered' do
          expect(node['WantAssertionsSigned'])
            .to eq(sp_sso_descriptor.want_assertions_signed.to_s)
        end
      end
    end
  end

  context 'AssertionConsumerService' do
    it 'is rendered' do
      expect(xml).to have_xpath(assertion_consumer_service_path, count: 1)
    end

    context 'multiple endpoints' do
      let(:sp_sso_descriptor) do
        create :sp_sso_descriptor, :with_multiple_assertion_consumer_services
      end
      it 'renders all' do
        expect(xml).to have_xpath(assertion_consumer_service_path, count: 3)
      end
    end
  end

  context 'AttributeConsumingService' do
    context 'when not populated' do
      it 'is not rendered' do
        expect(xml).not_to have_xpath(attribute_consuming_service_path)
      end
    end
    context 'when populated' do
      let(:sp_sso_descriptor) do
        create :sp_sso_descriptor, :with_attribute_consuming_services
      end
      it 'is rendered' do
        expect(xml).to have_xpath(attribute_consuming_service_path, count: 2)
      end
    end
  end

  context 'idpdisc:DiscoveryResponse' do
    context 'when not populated' do
      it 'is not rendered' do
        expect(xml).not_to have_xpath(idpdisc_discovery_response_path)
      end
    end
    context 'when populated' do
      let(:sp_sso_descriptor) do
        create :sp_sso_descriptor, :with_discovery_response_services
      end
      it 'is rendered' do
        expect(xml).to have_xpath(idpdisc_discovery_response_path, count: 1)
      end
    end
  end
end
