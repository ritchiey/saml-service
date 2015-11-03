module ETL
  module RoleDescriptors
    def role_descriptor(rd, rd_data, scopes_data)
      scopes(rd, scopes_data)
      contact_people(rd, rd_data[:contact_people])
      protocol_supports(rd, rd_data[:protocol_support_enumerations])
      key_descriptors(rd, rd_data[:key_descriptors])
    end

    def scopes(rd, scope_data)
      rd.scopes.each(&:destroy)
      rd.add_scope(SHIBMD::Scope.new(value: scope_data,
                                     regexp: regexp_scope?(scope_data)))
    end

    def contact_people(rd, contact_people)
      # Contacts are stored at the ED level only within saml-service
      # This is more inline with eduGain policy and prevents duplication
      rd.entity_descriptor.contact_people.each(&:destroy)
      contact_people.each do |contact_person|
        type = contact_person[:type][:name].to_sym
        next unless ContactPerson::TYPE.key?(type)

        c = rd_contact(contact_person)
        next unless c

        cp = ContactPerson.create(contact: c, contact_type: type)
        rd.entity_descriptor.add_contact_person(cp)
      end
    end

    def rd_contact(contact_person)
      FederationRegistryObject.local_instance(contact_person[:contact][:id],
                                              Contact.name)
    end

    def regexp_scope?(scope)
      !(scope =~ /\^(.+)\$/).nil?
    end

    def protocol_supports(rd, protocol_support_data)
      rd.protocol_supports.each(&:destroy)
      protocol_support_data.each do |ps|
        rd.add_protocol_support(ProtocolSupport.new(uri: ps[:uri]))
      end
    end

    def key_descriptors(rd, key_descriptor_data)
      rd.key_descriptors.each(&:destroy)

      key_descriptor_data.each do |kd_data|
        next if kd_data[:disabled]

        kd = KeyDescriptor.create(key_type: kd_data[:type].to_sym)
        key_encryption_method(kd, kd_data)
        key_info(kd, kd_data)
        rd.add_key_descriptor(kd)
      end
    end

    def key_encryption_method(kd, kd_data)
      return unless kd_data[:encryption_method][:algorithm].present?

      em_data = kd_data[:encryption_method]
      em = EncryptionMethod.new(algorithm: em_data[:algorithm],
                                key_size: em_data[:key_size],
                                oae_params: em_data[:oae_params])
      kd.add_encryption_method(em)
    end

    def key_info(kd, kd_data)
      ki_data = kd_data[:key_info]
      cert_data = ki_data[:certificate][:data].gsub(/(\n\n)/, "\n")
      ki = KeyInfo.create(key_name: ki_data[:name],
                          subject: ki_data[:certificate][:subject],
                          issuer: ki_data[:certificate][:issuer],
                          data: cert_data)

      kd.update(key_info: ki)
    end
  end
end
