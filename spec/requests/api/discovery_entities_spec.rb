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
  end
end
