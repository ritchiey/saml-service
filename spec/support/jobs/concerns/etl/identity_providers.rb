RSpec.shared_examples 'ETL::IdentityProviders' do
  # rubocop:disable Metrics/MethodLength
  def endpoint_json(s)
    {
      location: s.location,
      binding: {
        uri: s.binding
      },
      functioning: true
    }
  end

  def indexed_endpoint_json(s)
    {
      location: s.location,
      index: s.index,
      is_default: s.is_default,
      binding: {
        uri: s.binding
      },
      functioning: true
    }
  end

  def saml_uri_json(su)
    {
      uri: su.uri
    }
  end

  # rubocop:disable Metrics/AbcSize
  def create_json(idp)
    {
      id: idp.id,
      display_name: Faker::Lorem.sentence,
      description: Faker::Lorem.sentence,
      functioning: idp.functioning?,
      created_at: idp_created_at,
      saml: {
        scope: scope,
        authnrequests_signed: idp.want_authn_requests_signed,
        single_sign_on_services:
          idp.single_sign_on_services.map { |s| endpoint_json(s) },
        name_id_mapping_services:
          idp.name_id_mapping_services.map { |s| endpoint_json(s) },
        assertion_id_request_services:
          idp.assertion_id_request_services.map { |s| endpoint_json(s) },
        attribute_profiles:
          idp.attribute_profiles.map { |ap| saml_uri_json(ap) },
        attributes: attribute_instances.map { |a| attribute_json(a) },
        sso_descriptor: {
          role_descriptor: {
            protocol_support_enumerations:
              idp.protocol_supports.map { |pse| saml_uri_json(pse) },
            key_descriptors:
              idp.key_descriptors.map { |kd| key_descriptor_json(kd) }
                .push(bad_key_descriptor_json),
            contact_people:
              contact_instances.map { |cp| contact_person_json(cp) },
            error_url: idp.error_url
          },
          name_id_formats:
            idp.name_id_formats.map { |nidf| saml_uri_json(nidf) },
          artifact_resolution_services:
            idp.artifact_resolution_services.map do |ars|
              indexed_endpoint_json(ars)
            end,
          single_logout_services:
            idp.single_logout_services.map { |slo| endpoint_json(slo) },
          manage_nameid_services:
            idp.manage_name_id_services.map { |mnids| endpoint_json(mnids) }
        }
      }
    }
  end
  # rubocop:enable Metrics/AbcSize

  def key_descriptor_json(kd)
    {
      disabled: kd.disabled,
      type: kd.key_type,
      key_info: {
        certificate: {
          name: kd.key_info.key_name,
          subject: kd.key_info.subject,
          issuer: kd.key_info.issuer,
          data: kd.key_info.data
        }
      }
    }
  end

  def bad_key_descriptor_json
    {
      disabled: false,
      type: :signing,
      key_info: {
        certificate: {
          name: Faker::Lorem.word,
          subject: Faker::Lorem.word,
          issuer: Faker::Lorem.word,
          data: Faker::Lorem.word
        }
      }
    }
  end

  def contact_json(c)
    {
      id: c.id,
      given_name: c.given_name,
      surname: c.surname,
      email: c.email_address,
      work_phone: c.telephone_number,
      created_at: Time.at(rand(Time.now.utc.to_i))
    }
  end

  def contact_person_json(cp)
    {
      type: {
        name: ContactPerson::TYPE.keys[rand 0..4].to_s
      },
      contact: {
        id: cp.id
      }
    }
  end

  def attribute_json(a)
    {
      id: a[:id],
      name: Faker::Lorem.word
    }
  end

  def attribute_base_json(a)
    {
      id: a[:id],
      description: a[:description],
      oid: a[:oid],
      name_format: {
        uri: 'urn:oasis:names:tc:SAML:2.0:attrname-format:uri'
      }
    }
  end

  def fr_object(name, id)
    FederationRegistryObject.create(internal_class_name: name,
                                    internal_id: id, fr_id: id)
  end

  def run
    described_class.new(id: fr_source.id, primary_tag: federation_tag)
      .identity_providers(entity_descriptor, ed_data)
  end

  let(:identity_provider_instances) do
    create_list(:idp_sso_descriptor, idp_count,
                :with_requests_signed,
                :with_multiple_single_sign_on_services,
                :with_assertion_id_request_services,
                :with_name_id_mapping_services,
                :with_attribute_profiles,
                :with_attributes,
                :with_name_id_formats,
                :with_single_logout_services,
                :with_manage_name_id_services,
                :with_key_descriptors,
                :with_artifact_resolution_services,
                :with_disco_hints)
  end

  let(:identity_providers_list) do
    identity_provider_instances.map { |idp| create_json(idp) }
  end
  let(:identity_providers) { identity_providers_list }
  let(:idp_created_at) { Time.at(rand(Time.now.utc.to_i)) }
  let(:scope) { 'example.edu' }

  let(:contact_instances) do
    create_list(:contact, contact_count)
  end
  let(:contacts_list) do
    contact_instances.map { |ci| contact_json(ci) }
  end
  let(:contacts) { contacts_list }

  let(:attribute_instances) do
    (0..attribute_count).map do |i|
      {
        id: i,
        description: Faker::Lorem.sentence,
        oid: "#{Faker::Number.number(4)}:#{Faker::Number.number(4)}"
      }
    end
  end
  let(:attributes_list) do
    attribute_instances.map { |a| attribute_base_json(a) }
  end
  let(:attributes) { attributes_list }

  let(:entity_descriptor) { create :entity_descriptor }

  let(:ed_data) do
    {
      saml: {
        identity_providers:
          identity_provider_instances.map do |idp|
            { id: idp.id, functioning: idp.functioning? }
          end
      }
    }
  end

  shared_examples 'endpoint' do
    it 'has source data' do
      expect(source.count).to be > 0
    end

    it 'creates new instances' do
      expect(target.count)
        .to eq(source.count)
    end

    it 'sets expected locations' do
      source.each_with_index do |s, i|
        expect(target[i].location == s.location)
      end
    end

    it 'sets expected bindings' do
      source.each_with_index do |s, i|
        expect(target[i].binding == s.binding)
      end
    end
  end

  shared_examples 'indexed_endpoint' do
    include_examples 'endpoint'

    it 'sets is_default' do
      source.each_with_index do |s, i|
        expect(target[i].is_default).to eq(s.is_default)
      end
    end

    it 'sets index' do
      source.each_with_index do |s, i|
        expect(target[i].index).to eq(s.index)
      end
    end
  end

  shared_examples 'saml_uris' do
    it 'has source data' do
      expect(source.count).to be > 0
    end

    it 'creates new instances' do
      expect(target.count)
        .to eq(source.count)
    end

    it 'sets expected uri' do
      source.each_with_index do |s, i|
        expect(target[i].uri == s.uri)
      end
    end
  end

  shared_examples 'saml_attributes' do
    it 'has source data' do
      expect(source.count).to be > 0
    end

    it 'creates new instances' do
      expect(target.count)
        .to eq(source.count)
    end

    it 'sets name' do
      source.each_with_index do |s, i|
        expect(target[i].name) == "urn:oid:#{s[:oid]}"
      end
    end

    it 'sets friendly_name' do
      source.each_with_index do |s, i|
        expect(target[i].friendly_name == s[:name])
      end
    end

    it 'sets description' do
      source.each_with_index do |s, i|
        expect(target[i].description == s[:description])
      end
    end

    it 'sets oid' do
      source.each_with_index do |s, i|
        expect(target[i].oid == s[:oid])
      end
    end
  end

  shared_examples 'key_descriptors' do
    it 'has source data' do
      expect(source.count).to be > 0
    end

    it 'creates new instances' do
      expect(target.count)
        .to eq(source.count)
    end

    it 'sets type' do
      source.each_with_index do |s, i|
        expect(target[i].key_type).to eq(s.key_type)
      end
    end

    context 'key info' do
      it 'sets key_name' do
        source.each_with_index do |s, i|
          expect(target[i].key_info.key_name).to eq(s.key_info.key_name)
        end
      end

      it 'sets subject' do
        source.each_with_index do |s, i|
          expect(target[i].key_info.subject).to eq(s.key_info.subject)
        end
      end

      it 'sets issuer' do
        source.each_with_index do |s, i|
          expect(target[i].key_info.issuer).to eq(s.key_info.issuer)
        end
      end

      it 'sets certificate PEM data' do
        source.each_with_index do |s, i|
          expect(target[i].key_info.data).to eq(s.key_info.data)
        end
      end
    end
  end

  shared_examples 'contact_people' do
    it 'has source data' do
      expect(source.count).to be > 0
    end

    it 'creates new instances' do
      expect(target.count)
        .to eq(source.count)
    end

    it 'has source types' do
      source.each_with_index do |s, i|
        expect(target[i].contact_type.to_s).to eq(s[:type][:name])
      end
    end

    it 'has email' do
      source.each_with_index do |_s, i|
        expect(target[i].contact.email_address)
          .to eq(contact_instances[i].email_address)
      end
    end

    it 'has given_name' do
      source.each_with_index do |_s, i|
        expect(target[i].contact.given_name)
          .to eq(contact_instances[i].given_name)
      end
    end

    it 'has surname' do
      source.each_with_index do |_s, i|
        expect(target[i].contact.surname)
          .to eq(contact_instances[i].surname)
      end
    end
  end

  before do
    stub_fr_request(:contacts)
    contact_instances.each { |c| fr_object(Contact.name, c.id) }

    stub_fr_request(:attributes)
    stub_fr_request(:identity_providers)
  end

  context 'creating an IDPSSODescriptor' do
    let(:source_idp) { identity_provider_instances.first }
    let(:idp_count) { 1 }
    let(:contact_count) { 1 }
    let(:attribute_count) { 3 }

    subject { IDPSSODescriptor.last }

    it 'creates a new instance' do
      expect { run }.to change { IDPSSODescriptor.count }.by(idp_count)
    end

    context 'created instance' do
      before { run }

      context 'correct attributes' do
        verify(created_at: -> { idp_created_at },
               updated_at: -> { truncated_now },
               error_url: -> { source_idp.error_url },
               want_authn_requests_signed:
                 -> { source_idp.want_authn_requests_signed })
      end

      context 'scopes' do
        it 'sets a scope' do
          expect(subject.scopes.size).to eq(1)
        end

        it 'sets expected scope' do
          expect(subject.scopes.first.value).to eq(scope)
        end

        context 'normal scope' do
          it 'sets regex to false' do
            expect(subject.scopes.first.regexp).not_to be
          end
        end

        context 'regex scope' do
          let(:scope) { '^([a-zA-Z0-9-]{1,63}[.]){0,2}example.edu$' }

          it 'sets regex to true' do
            expect(subject.scopes.first.regexp).to be
          end
        end
      end

      context 'single_sign_on_services' do
        include_examples 'endpoint' do
          let(:target) { subject.single_sign_on_services }
          let(:source) { source_idp.single_sign_on_services }
        end
      end

      context 'name_id_mapping_services' do
        include_examples 'endpoint' do
          let(:target) { subject.name_id_mapping_services }
          let(:source) { source_idp.name_id_mapping_services }
        end
      end

      context 'assertion_id_request_services' do
        include_examples 'endpoint' do
          let(:target) { subject.assertion_id_request_services }
          let(:source) { source_idp.assertion_id_request_services }
        end
      end

      context 'attribute_profiles' do
        include_examples 'saml_uris' do
          let(:target) { subject.attribute_profiles }
          let(:source) { source_idp.attribute_profiles }
        end
      end

      context 'attribute_instances' do
        include_examples 'saml_attributes' do
          let(:target) { subject.attributes }
          let(:source) { attribute_instances }
        end
      end

      context 'protocol supports' do
        include_examples 'saml_uris' do
          let(:target) { subject.protocol_supports }
          let(:source) { source_idp.protocol_supports }
        end
      end

      context 'key descriptors' do
        include_examples 'key_descriptors' do
          let(:target) { subject.key_descriptors }
          let(:source) { source_idp.key_descriptors }
        end
      end

      context 'contact people' do
        include_examples 'contact_people' do
          let(:target) { subject.entity_descriptor.contact_people }
          let(:source) do
            identity_providers
              .first[:saml][:sso_descriptor][:role_descriptor][:contact_people]
          end
        end
      end

      context 'nameid formats' do
        include_examples 'saml_uris' do
          let(:target) { subject.name_id_formats }
          let(:source) { source_idp.name_id_formats }
        end
      end

      context 'artifact resolution services' do
        include_examples 'indexed_endpoint' do
          let(:target) { subject.artifact_resolution_services }
          let(:source) { source_idp.artifact_resolution_services }
        end
      end

      context 'single logout services' do
        include_examples 'endpoint' do
          let(:target) { subject.single_logout_services }
          let(:source) { source_idp.single_logout_services }
        end
      end

      context 'manage nameid services' do
        include_examples 'endpoint' do
          let(:target) { subject.manage_name_id_services }
          let(:source) { source_idp.manage_name_id_services }
        end
      end
    end
  end

  shared_examples 'updating a RoleDescriptor' do
    it 're-uses contact instances' do
      expect { run }.not_to change { Contact.count }
    end

    it 'updates contact people' do
      expect { run }
        .to change { subject.entity_descriptor.reload.contact_people }
    end

    it 'updates protocol supports' do
      expect { run }.to change { subject.reload.protocol_supports }
    end

    it 'updates key descriptors' do
      expect { run }.to change { subject.reload.key_descriptors }
    end

    it 'updates mdui display_names' do
      expect { run }.to change { subject.reload.ui_info.display_names }
    end

    it 'updates mdui descriptions' do
      expect { run }.to change { subject.reload.ui_info.descriptions }
    end
  end

  shared_examples 'updating an SSODescriptor' do
    include_examples 'updating a RoleDescriptor'

    it 'updates name id formats' do
      expect { run }.to change { subject.reload.name_id_formats }
    end

    it 'updates artifact resolution services' do
      expect { run }.to change { subject.reload.artifact_resolution_services }
    end

    it 'updates single_logout_services' do
      expect { run }.to change { subject.reload.single_logout_services }
    end

    it 'updates manage name id services' do
      expect { run }.to change { subject.reload.manage_name_id_services }
    end
  end

  context 'updating an IDPSSODescriptor' do
    context 'creating an IDPSSODescriptor' do
      let(:source_idp) { identity_provider_instances.first }
      let(:idp_count) { 1 }
      let(:contact_count) { 1 }
      let(:attribute_count) { 3 }

      subject { IDPSSODescriptor.last }

      before { run }

      include_examples 'updating an SSODescriptor'

      it 'uses the existing instance' do
        expect { run }.not_to change { IDPSSODescriptor.count }
      end

      it 'updates single sign on services' do
        expect { run }.to change { subject.reload.single_sign_on_services }
      end

      it 'updates name id mapping services' do
        expect { run }.to change { subject.reload.name_id_mapping_services }
      end

      it 'updates assertion id request services' do
        expect { run }
          .to change { subject.reload.assertion_id_request_services }
      end

      it 'updates attribute profiles' do
        expect { run }.to change { subject.reload.attribute_profiles }
      end

      it 'updates attributes' do
        expect { run }.to change { subject.reload.attributes }
      end
    end
  end
end
