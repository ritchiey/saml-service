require 'metadata/saml_namespaces'

module Metadata
  class SAML
    include SAMLNamespaces

    attr_reader :builder
    attr_accessor :federation_identifier, :metadata_name,
                  :metadata_validity_period

    def initialize
      @builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8')
    end

    def root_entities_descriptor(entities_descriptor)
      created_at = Time.now.utc
      expires_at = created_at + metadata_validity_period
      attrs = { ID: "#{federation_identifier}"\
                    "#{created_at.to_formatted_s(:number)}",
                Name: metadata_name,
                validUntil: expires_at.xmlschema }

      root.EntitiesDescriptor(ns, attrs) do |_|
        entities_descriptor_extensions(entities_descriptor)
      end
    end

    def entities_descriptor_extensions(ed)
      return unless ed.ca_keys?

      root.Extensions do |_|
        key_authority(ed) if ed.ca_keys?
      end
    end

    def key_authority(ed)
      shibmd.KeyAuthority(VerifyDepth: ed.ca_verify_depth) do |_|
        ed.ca_key_infos.each do |ca|
          key_info(ca)
        end
      end
    end

    def key_info(ki)
      ds.KeyInfo(ns) do |_|
        ds.KeyName ki.key_name if ki.key_name
        ds.X509Data do |_|
          ds.X509SubjectName ki.subject if ki.subject
          ds.X509Certificate ki.certificate_without_anchors
        end
      end
    end

    def to_xml
      builder.to_xml
    end
  end
end
