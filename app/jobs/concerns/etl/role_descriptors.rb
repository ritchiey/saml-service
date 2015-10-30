module ETL
  module RoleDescriptors
    def role_descriptor(rd, rd_data, scopes_data)
      scopes(rd, scopes_data)
      protocol_supports(rd, rd_data[:protocol_support_enumerations])
      key_descriptors(rd, rd_data[:key_descriptors])
    end

    def scopes(rd, scope_data)
      rd.scopes.each(&:destroy)
      rd.add_scope(SHIBMD::Scope.new(value: scope_data,
                                     regexp: regexp_scope?(scope_data)))
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

        if kd_data[:encryption_method][:algorithm].present?
          em_data = kd_data[:encryption_method]
          em = EncryptionMethod.new(algorithm: em_data[:algorithm],
                                    key_size: em_data[:key_size],
                                    oae_params: em_data[:oae_params])
          kd.add_encryption_method(em)
        end

        ki_data = kd_data[:key_info]
        cert_data = ki_data[:certificate][:data].gsub(/(\n\n)/, "\n")
        ki = KeyInfo.create(key_name: ki_data[:name],
                            subject: ki_data[:certificate][:subject],
                            issuer: ki_data[:certificate][:issuer],
                            data: cert_data)
        kd.update(key_info: ki)
        rd.add_key_descriptor(kd)
      end
    end
  end
end
