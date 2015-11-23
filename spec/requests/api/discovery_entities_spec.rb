require 'rails_helper'

RSpec.describe API::DiscoveryEntitiesController, type: :request do
  subject { response }

  let(:json) { JSON.parse(response.body, symbolize_names: true) }

  context 'get /api/discovery/entities' do
    def run
      get '/api/discovery/entities', nil, headers
    end

    let!(:identity_providers) { create_list(:entity_descriptor, 1) }
    let!(:service_providers) { create_list(:entity_descriptor, 1) }

    let!(:idp_sso_descriptors) do
      identity_providers.map do |idp|
        create(:idp_sso_descriptor, entity_descriptor: idp)
      end
    end

    let!(:sp_sso_descriptors) do
      service_providers.map do |sp|
        create(:sp_sso_descriptor, entity_descriptor: sp)
      end
    end

    # Lets us create things in nested contexts before the `before { run }`
    let!(:extras) { nil }

    before { run }

    it { is_expected.to have_http_status(:ok) }

    # {
    #   "identity_providers":[
    #     {
    #       "entity_id": "https://idp.example.edu/idp/shibboleth",
    #       "names":[
    #         {
    #           "value":"Example University",
    #           "lang":"en"
    #         }
    #       ],
    #       "tags":[
    #         "discovery",
    #         "aaf"
    #       ],
    #       "logos": [
    #         {
    #           "uri": "https://example.edu/static/logo.jpg",
    #           "lang": "en"
    #         }
    #       ],
    #       "descriptions": [
    #         {
    #           "value": "Example University is a university for examples",
    #           "lang": "en"
    #         }
    #       ],
    #       "geolocations" : [{ "longitude": 26.38695, "latitude": 69.395142 }],
    #       "domains" : ["example.edu"]
    #     }
    #   ]
    # }
    context 'identity_providers' do
      subject { json[:identity_providers] }

      let(:identity_provider) { identity_providers.first }
      let(:idp_sso_descriptor) { identity_provider.idp_sso_descriptors.first }

      let(:idp_entry) do
        subject.find do |idp|
          idp[:entity_id] == identity_provider.entity_id.uri
        end
      end

      it 'includes the entity id' do
        expect(subject.map { |idp| idp[:entity_id] })
          .to include(identity_provider.entity_id.uri)
      end

      context 'with no mdui info' do
        it 'includes an empty list of display names' do
          expect(idp_entry[:names]).to eq([])
        end

        it 'includes an empty list of logos' do
          expect(idp_entry[:logos]).to eq([])
        end

        it 'includes an empty list of descriptions' do
          expect(idp_entry[:descriptions]).to eq([])
        end
      end

      context 'with no disco hints' do
        it 'includes an empty list of geolocation data' do
          expect(idp_entry[:geolocations]).to eq([])
        end

        it 'includes an empty list of domain hints' do
          expect(idp_entry[:domains]).to eq([])
        end
      end

      context 'with mdui info' do
        let!(:idp_sso_descriptors) do
          identity_providers.map do |idp|
            create(:idp_sso_descriptor, :with_ui_info, entity_descriptor: idp)
          end
        end

        it 'includes the display names' do
          display_name = idp_sso_descriptor.ui_info.display_names.first
          expect(idp_entry[:names])
            .to include(value: display_name.value, lang: display_name.lang)
        end

        it 'includes the logo uri' do
          logo = idp_sso_descriptor.ui_info.logos.first
          expect(idp_entry[:logos]).to include(uri: logo.uri, lang: logo.lang)
        end

        it 'includes the descriptions' do
          description = idp_sso_descriptor.ui_info.descriptions.first
          expect(idp_entry[:descriptions])
            .to include(value: description.value, lang: description.lang)
        end
      end

      context 'with disco hints' do
        let!(:idp_sso_descriptors) do
          identity_providers.map do |idp|
            create(:idp_sso_descriptor, :with_disco_hints,
                   entity_descriptor: idp).tap do |rd|
              create(:mdui_geolocation_hint, disco_hints: rd.disco_hints)
            end
          end
        end

        it 'includes the geolocation data' do
          geo = idp_sso_descriptor.disco_hints.geolocation_hints.first.uri
          match = geo.match(/^geo:(?<lat>[\d.]+),(?<long>[\d.]+)/)
          expect(idp_entry[:geolocations])
            .to include(latitude: match[:lat], longitude: match[:long])
        end

        context 'when geolocation data includes altitude' do
          let!(:idp_sso_descriptors) do
            identity_providers.map do |idp|
              create(:idp_sso_descriptor, entity_descriptor: idp).tap do |rd|
                disco_hints = create(:mdui_disco_hint, idp_sso_descriptor: rd)
                create(:mdui_geolocation_hint, :with_altitude,
                       disco_hints: disco_hints)
              end
            end
          end

          it 'includes the geolocation data' do
            geo = idp_sso_descriptor.disco_hints.geolocation_hints.first.uri
            regexp = /^geo:(?<lat>[\d.]+),(?<long>[\d.]+),(?<alt>[\d.]+)/
            match = geo.match(regexp)

            expect(idp_entry[:geolocations])
              .to include(latitude: match[:lat], longitude: match[:long],
                          altitude: match[:alt])
          end
        end

        it 'includes the domain hints' do
          domain = idp_sso_descriptor.disco_hints.domain_hints.first.domain
          expect(idp_entry[:domains]).to include(domain)
        end
      end

      context 'when the identity provider is not tagged' do
        it 'includes an empty tag list' do
          expect(idp_entry[:tags]).to eq([])
        end
      end

      context 'when the identity provider is tagged' do
        let(:tags) { Faker::Lorem.words }

        let!(:extras) do
          tags.map do |tag|
            Tag.create(name: tag, role_descriptor: idp_sso_descriptor)
          end
        end

        it 'includes the tags' do
          expect(idp_entry[:tags]).to contain_exactly(*tags)
        end
      end
    end

    # "service_providers":[
    #   {
    #     "entity_id":"https://example.edu/shibboleth",
    #     "discovery_response":"https://example.edu/Shibboleth.sso/Login",
    #     "all_discovery_response_endpoints: [
    #       "https://example.edu/Shibboleth.sso/Login",
    #       "https://example.edu/Shibboleth.sso/AnotherLogin",
    #       "https://example.edu/Shibboleth.sso/YetAnotherLogin"
    #     ],
    #     "names":[
    #       {
    #         "value":"Example University SP",
    #         "lang":"en"
    #       }
    #     ],
    #     "tags":[
    #       "aaf"
    #     ],
    #     "logos": [
    #       {
    #         "uri": "https://example.edu/static/logo.png",
    #         "lang": "en"
    #       }
    #     ],
    #     "descriptions": [
    #       {
    #         "value": "Example University federated service",
    #         "lang": "en"
    #       }
    #     ],
    #     "information_urls": [
    #       {
    #         "uri": "https://example.edu/info",
    #         "lang": "en"
    #       }
    #     ],
    #     "privacy_statement_urls": [
    #       {
    #         "uri": "https://example.edu/privacy",
    #         "lang": "en"
    #       }
    #     ]
    #   },
    #   ...
    # ]
    context 'service_providers' do
      subject { json[:service_providers] }

      let(:service_provider) { service_providers.first }
      let(:sp_sso_descriptor) { service_provider.sp_sso_descriptors.first }

      let(:sp_entry) do
        subject.find do |sp|
          sp[:entity_id] == service_provider.entity_id.uri
        end
      end

      it 'includes the entity id' do
        expect(subject.map { |sp| sp[:entity_id] })
          .to include(service_provider.entity_id.uri)
      end

      context 'with discovery response services' do
        context 'with a default' do
          let(:non_default) do
            create(:discovery_response_service,
                   is_default: false, sp_sso_descriptor: sp_sso_descriptor)
          end

          let(:default) do
            create(:discovery_response_service,
                   is_default: true, sp_sso_descriptor: sp_sso_descriptor)
          end

          let!(:extras) do
            non_default
            default
          end

          it 'includes the default discovery response location' do
            expect(sp_entry[:discovery_response]).to eq(default.location)
          end

          context 'when multiple defaults exist' do
            let(:second_default) do
              create(:discovery_response_service,
                     is_default: true, sp_sso_descriptor: sp_sso_descriptor)
            end

            let!(:extras) do
              non_default
              default
              second_default
            end

            it 'includes the "first" default' do
              expect(sp_entry[:discovery_response]).to eq(default.location)
            end

            it 'lists all the endpoints' do
              endpoints = [non_default, default, second_default].map(&:location)
              expect(sp_entry[:all_discovery_response_endpoints])
                .to contain_exactly(*endpoints)
            end
          end
        end

        context 'with no default' do
          let(:preferred) do
            create(:discovery_response_service,
                   is_default: false, sp_sso_descriptor: sp_sso_descriptor)
          end

          let(:non_preferred) do
            create(:discovery_response_service,
                   is_default: false, sp_sso_descriptor: sp_sso_descriptor)
          end

          let!(:extras) do
            preferred
            non_preferred
          end

          it 'includes the preferred endpoint' do
            expect(sp_entry[:discovery_response]).to eq(preferred.location)
          end

          it 'lists all the endpoints' do
            endpoints = [preferred, non_preferred].map(&:location)
            expect(sp_entry[:all_discovery_response_endpoints])
              .to contain_exactly(*endpoints)
          end
        end
      end

      context 'with no tags' do
        it 'returns an empty tag list' do
          expect(sp_entry[:tags]).to eq([])
        end
      end

      context 'with tags' do
        let(:tags) do
          create_list(:role_descriptor_tag, 3,
                      role_descriptor: sp_sso_descriptor)
        end

        let!(:extras) { tags }

        it 'returns the tags' do
          expect(sp_entry[:tags]).to contain_exactly(*tags.map(&:name))
        end
      end

      context 'with no mdui info' do
        it 'includes an empty list of display names' do
          expect(sp_entry[:names]).to eq([])
        end

        it 'includes an empty list of logos' do
          expect(sp_entry[:logos]).to eq([])
        end

        it 'includes an empty list of descriptions' do
          expect(sp_entry[:descriptions]).to eq([])
        end

        it 'includes an empty list of information urls' do
          expect(sp_entry[:information_urls]).to eq([])
        end

        it 'includes an empty list of privacy statement urls' do
          expect(sp_entry[:privacy_statement_urls]).to eq([])
        end
      end

      context 'with mdui info' do
        let!(:sp_sso_descriptors) do
          service_providers.map do |sp|
            create(:sp_sso_descriptor, :with_ui_info, entity_descriptor: sp)
          end
        end

        it 'includes the display names' do
          display_name = sp_sso_descriptor.ui_info.display_names.first
          expect(sp_entry[:names])
            .to include(value: display_name.value, lang: display_name.lang)
        end

        it 'includes the logo uri' do
          logo = sp_sso_descriptor.ui_info.logos.first
          expect(sp_entry[:logos]).to include(uri: logo.uri, lang: logo.lang)
        end

        it 'includes the descriptions' do
          description = sp_sso_descriptor.ui_info.descriptions.first
          expect(sp_entry[:descriptions])
            .to include(value: description.value, lang: description.lang)
        end

        it 'includes the information urls' do
          info_url = sp_sso_descriptor.ui_info.information_urls.first
          expect(sp_entry[:information_urls])
            .to include(uri: info_url.uri, lang: info_url.lang)
        end

        it 'includes the information urls' do
          privacy_url = sp_sso_descriptor.ui_info.privacy_statement_urls.first
          expect(sp_entry[:privacy_statement_urls])
            .to include(uri: privacy_url.uri, lang: privacy_url.lang)
        end
      end
    end
  end
end
