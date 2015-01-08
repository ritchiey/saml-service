require 'rails_helper'

require 'metadata/saml'

RSpec.describe Metadata::SAML do
  let(:builder) { subject.builder }
  let(:raw_xml) { builder.to_xml }
  let(:xml) do
    # Pull out xmlns so our tests don't need to specify it everywhere
    # as we expect metadata nodes to live under this namespace by default
    raw_xml.sub!('xmlns="urn:oasis:names:tc:SAML:2.0:metadata"','')
    Capybara::Node::Simple.new(Nokogiri::XML.parse(raw_xml))
  end

  include_examples 'SAML namespaces'

end
