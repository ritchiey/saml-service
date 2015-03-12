require 'rails_helper'

RSpec.describe UpdateFromFederationRegistry do
  RSpec::Matchers.define(:have_fr_id) do |expected|
    match do |actual|
      fr_id = FederationRegistryObject
              .where(object_type: actual.class.name, object_id: actual.id)
              .first.try(:fr_id)

      fr_id == expected
    end

    description { "have Federation Registry ID: #{expected}" }
  end

  def record_fr_id(object, fr_id)
    FederationRegistryObject.create(object_type: object.class.name,
                                    object_id: object.id,
                                    fr_id: fr_id)
  end

  let(:authorization) do
    %(AAF-FR-EXPORT service="saml-service", key="#{fr_source.secret}")
  end

  let(:request_headers) { { 'Authorization' => authorization } }
  let(:entity_ids) { entity_descriptors.map { |ed| ed[:entity_id] } }
  let(:idp_count) { 0 }
  let(:sp_count) { 0 }
  let(:truncated_now) { Time.at(Time.now.to_i) }

  delegate :entity_source, to: :fr_source
  delegate :known_entities, to: :entity_source

  let(:fr_source) { create(:federation_registry_source) }
  subject { fr_source }

  def stub_fr_request(kind)
    url = "https://#{fr_source.hostname}/federationregistry/export/" \
      "#{kind.to_s.sub('_', '')}"

    stub_request(:get, url).with(headers: request_headers)
      .to_return(status: 200, body: JSON.generate(kind => send(kind)))
  end

  around { |e| Timecop.freeze { e.run } }

  before do
    stub_fr_request(:entity_descriptors)
    stub_fr_request(:identity_providers)
    stub_fr_request(:service_providers)
    stub_fr_request(:attribute_authorities)
  end

  def run
    described_class.perform(fr_source.id)
  end

  def self.verify_attributes(attr_generators)
    attr_generators.each do |attr, value|
      v = value.is_a?(Proc) ? value : -> { value }

      it "has an updated `#{attr}` attribute" do
        expect(subject).to have_attributes(attr => instance_exec(&v))
      end
    end
  end

  def self.verify_checked_all_attributes(attrs)
    it 'has all attributes validated' do
      expect((attrs - [:id]).uniq).to contain_exactly(*attrs.uniq)
    end
  end

  def self.verify(attr_generators)
    verify_attributes(attr_generators)
    verify_checked_all_attributes(attr_generators.keys)

    it 'is valid' do
      skip
      expect(subject).to be_valid
    end
  end

  context 'with a single idp' do
    let(:idp_count) { 1 }

    it 'creates the entity' do
      expect { run }.to change { known_entities(true).count }.by(1)
    end

    it 'creates the entity descriptor' do
      expect { run }.to change(EntityDescriptor, :count).by(1)
    end

    it 'associates the entity descriptor with its fr id' do
      run
      expect(EntityDescriptor.last).to have_fr_id(1)
    end

    it 'assigns the entity the correct id' do
      run
      expect(known_entities.map(&:entity_id)).to contain_exactly(*entity_ids)
    end

    it 'creates the idp sso descriptor' do
      expect { run }.to change(IDPSSODescriptor, :count).by(1)
    end

    context 'the created idp sso descriptor' do
      before { run }
      subject { IDPSSODescriptor.last }

      let(:ed) { EntityDescriptor.last }

      verify(want_authn_requests_signed: false,
             active: true,
             created_at: -> { idp_created_at },
             updated_at: -> { truncated_now },
             entity_descriptor_id: -> { ed.id },
             error_url: -> { idp_error_url },
             extensions: -> { idp_extensions },
             kind: 'IDPSSODescriptor',
             organization_id: -> { skip })

      context 'with authn requests signed' do
        let(:idp_signed) { true }

        verify_attributes(want_authn_requests_signed: true)
      end

      context 'when inactive' do
        let(:idp_active) { false }

        verify_attributes(active: false)
      end
    end
  end

  context 'with an existing idp' do
    let(:idp_count) { 1 }

    let!(:idp_sso_descriptor) { create(:idp_sso_descriptor) }
    let!(:entity_descriptor) { idp_sso_descriptor.entity_descriptor }

    before do
      record_fr_id(entity_descriptor, entity_descriptors[0][:id])
      record_fr_id(idp_sso_descriptor, identity_providers[0][:id])
    end

    it 'creates no entity' do
      expect { run }.not_to change { known_entities(true).count }
    end

    it 'creates no entity descriptor' do
      expect { run }.not_to change(EntityDescriptor, :count)
    end

    it 'creates no idp sso descriptor' do
      expect { run }.not_to change(IDPSSODescriptor, :count)
    end
  end

  let(:entity_descriptors) do
    result = []
    n = 0

    identity_providers.zip(attribute_authorities).each do |(idp, aa)|
      n += 1
      result << {
        id: n,
        entity_id: "https://#{Faker::Lorem.words.join('.')}/idp/shibboleth",
        saml: {
          identity_providers: [{ id: idp[:id] }],
          service_providers: [],
          attribute_authorities: [{ id: aa[:id] }]
        }
      }
    end

    service_providers.each do |sp|
      n += 1
      result << {
        entity_id: "https://#{Faker::Lorem.words.join('.')}/shibboleth",
        saml: {
          identity_providers: [],
          service_providers: [{ id: sp[:id] }],
          attribute_authorities: []
        }
      }
    end

    result
  end

  def fr_time(time)
    time.utc.strftime('%Y-%m-%dT%H:%M:%S+0000')
  end

  let(:idp_created_at) { Time.at(rand(Time.now.to_i)) }
  let(:idp_signed) { false }
  let(:idp_active) { true }
  let(:idp_error_url) { "https://error.#{Faker::Internet.domain_name}" }
  let(:idp_extensions) { '<external:SomeExtension></external:SomeExtension>' }

  let(:identity_providers) do
    (1..idp_count).to_a.map do |i|
      {
        id: (1000 + i),
        active: idp_active,
        created_at: fr_time(idp_created_at),
        saml: {
          authnrequests_signed: idp_signed,
          sso_descriptor: {
            role_descriptor: {
              extensions: idp_extensions,
              error_url: idp_error_url
            }
          }
        }
      }
    end
  end

  let(:service_providers) do
    (1..sp_count).to_a.map do |i|
      {
        id: (2000 + i)
      }
    end
  end

  let(:attribute_authorities) do
    (1..idp_count).to_a.map do |i|
      {
        id: (3000 + i)
      }
    end
  end
end
