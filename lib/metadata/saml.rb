require 'metadata/saml_namespaces'

module Metadata
  class SAML
    include SAMLNamespaces

    attr_reader :builder
    attr_accessor :federation_identifier, :metadata_name,
                  :metadata_validity_period, :ca_key_infos, :ca_verify_depth

    def initialize
      @builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8')
    end

    def root_entities_descriptor
      attrs = { ID: "#{federation_identifier}"\
                    "#{Time.now.utc.to_formatted_s(:number)}",
                Name: metadata_name,
                validUntil: (Time.now.utc + metadata_validity_period)
                            .xmlschema }

      root.EntitiesDescriptor(ns, attrs) do |_|
      end
    end

    def to_xml
      builder.to_xml
    end
  end
end
