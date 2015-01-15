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
      attributes = { ID: instance_id,
                     Name: metadata_name,
                     validUntil: expires_at.xmlschema }

      entities_descriptor(entities_descriptor, attributes, true)
    end

    def entities_descriptor(entities_descriptor, attributes = {},
                            root_node = false)
      root.EntitiesDescriptor(ns, attributes) do |_|
        entities_descriptor_extensions(entities_descriptor, root_node)
        entities_descriptor.entities_descriptors.each do |ed|
          entities_descriptor(ed)
        end
        entities_descriptor.entity_descriptors.each do |ed|
          entity_descriptor(ed)
        end
      end
    end

    def entities_descriptor_extensions(ed, root_node)
      return unless ed.ca_keys? || root_node
      root.Extensions do |_|
        publication_info(ed) if root_node
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

    def publication_info(ed)
      publication_info = ed.locate_publication_info
      mdrpi.PublicationInfo(publisher: publication_info.publisher,
                            creationInstant: created_at.xmlschema,
                            publicationId: instance_id) do |_|
        publication_info.usage_policies.each do |up|
          mdrpi.UsagePolicy(lang: up.lang) do |_|
            root.text up.uri
          end
        end
      end
    end

    def root_entity_descriptor(ed)
      attributes = { ID: instance_id,
                     validUntil: expires_at.xmlschema }
      entity_descriptor(ed, attributes)
    end

    def entity_descriptor(ed, attributes = {})
      root.EntityDescriptor(ns, attributes, entityID: ed.entity_id.uri) do |_|
      end
    end

    def to_xml
      builder.to_xml
    end
  end
end
