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

    def root_entities_descriptor
      created_at = Time.now.utc
      expires_at = created_at + metadata_validity_period
      attrs = { ID: "#{federation_identifier}"\
                    "#{created_at.to_formatted_s(:number)}",
                Name: metadata_name,
                validUntil: expires_at.xmlschema }

      root.EntitiesDescriptor(ns, attrs) do |_|
      end
    end

    def to_xml
      builder.to_xml
    end
  end
end
