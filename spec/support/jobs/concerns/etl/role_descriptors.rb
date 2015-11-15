RSpec.shared_examples 'ETL::RoleDescriptors' do
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

  # rubocop:disable Metrics/MethodLength
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
  # rubocop:enable Metrics/MethodLength

  let(:scope) { 'example.edu' }

  let(:contact_instances) do
    create_list(:contact, contact_count)
  end
  let(:contacts_list) do
    contact_instances.map { |ci| contact_json(ci) }
  end
  let(:contacts) { contacts_list }
end
