require 'metadata/saml_namespaces'

module Metadata
  class SAML
    include SAMLNamespaces

    attr_reader :builder, :created_at, :expires_at, :instance_id,
                :federation_identifier, :metadata_name,
                :metadata_validity_period

    def initialize(params)
      params.each do |k, v|
        instance_variable_set("@#{k}", v)
      end

      @builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8')
      @created_at = Time.now.utc
      @expires_at = created_at + metadata_validity_period
      @instance_id = "#{federation_identifier}" \
                     "#{created_at.to_formatted_s(:number)}"
    end

    def root_entities_descriptor(entities_descriptor)
      attrs = { ID: instance_id,
                Name: metadata_name,
                validUntil: expires_at.xmlschema }

      root.EntitiesDescriptor(ns, attrs) do |_|
        entities_descriptor_extensions(entities_descriptor)
      end
    end

    def entities_descriptor_extensions(ed)
      return unless ed.ca_keys? || ed.publication_info?

      root.Extensions do |_|
        key_authority(ed) if ed.ca_keys?
        publication_info(ed) if ed.publication_info?
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

    def publication_info(ed)
      mdrpi.PublicationInfo(publisher: ed.publication_info.publisher,
                            creationInstant: created_at.xmlschema,
                            publicationId: instance_id) do |_|
        ed.publication_info.usage_policies.each do |up|
          mdrpi.UsagePolicy(lang: up.lang) do |_|
            root.text up.uri
          end
        end
      end
    end

    def to_xml
      builder.to_xml
    end
  end
end
