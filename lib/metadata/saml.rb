require 'metadata/saml_namespaces'

module Metadata
  class SAML
    include SAMLNamespaces
    attr_reader :builder

    def initialize
      @builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8')
    end
  end
end
