# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SetSAMLTypeFromXML do
  let(:known_entity) { spy(KnownEntity) }
  let(:red) { spy(RawEntityDescriptor, known_entity: known_entity) }
  let(:ed_node) { double(Nokogiri::XML::Node) }
  let(:klass) { Class.new { include SetSAMLTypeFromXML } }
  let(:absent_role_descriptor) { nil }
  let(:present_role_descriptor) { double(present?: true) }
  let(:idp_sso_descriptor) { absent_role_descriptor }
  let(:attribute_authority_descriptor) { absent_role_descriptor }
  let(:sp_sso_descriptor) { absent_role_descriptor }

  let(:xpath_results) do
    {
      'IDPSSODescriptor' => idp_sso_descriptor,
      'AttributeAuthorityDescriptor' => attribute_authority_descriptor,
      'SPSSODescriptor' => sp_sso_descriptor
    }
  end

  subject { klass.new }

  before do
    allow(ed_node).to receive(:xpath) do |path|
      prefix = '//*[local-name() = "'
      suffix = '" and namespace-uri() = "urn:oasis:names:tc:SAML:2.0:metadata"]'
      pattern = "#{Regexp.escape(prefix)}(\\w+)#{Regexp.escape(suffix)}"
      match = Regexp.new(pattern).match(path)

      expect(match).to be_present
      expect(xpath_results).to have_key(match[1])
      xpath_results[match[1]]
    end
  end

  describe '.set_saml_type' do
    before { subject.set_saml_type(red, ed_node) }

    # Sanity check; the XML would be invalid anyway
    context 'with no type' do
      it 'removes the flags' do
        expect(red).to have_received(:update)
          .with(idp: false, sp: false, standalone_aa: false)
      end

      it 'removes the tags' do
        expect(known_entity).to have_received(:untag_as).with('idp')
        expect(known_entity).to have_received(:untag_as).with('aa')
        expect(known_entity).to have_received(:untag_as).with('sp')
        expect(known_entity).to have_received(:untag_as).with('standalone-aa')
      end
    end

    context 'with an IDPSSODescriptor' do
      let(:idp_sso_descriptor) { present_role_descriptor }

      it 'sets the flags' do
        expect(red).to have_received(:update)
          .with(idp: true, sp: false, standalone_aa: false)
      end

      it 'adds the tag' do
        expect(known_entity).to have_received(:tag_as).with('idp')
      end

      it 'removes the other tags' do
        expect(known_entity).to have_received(:untag_as).with('aa')
        expect(known_entity).to have_received(:untag_as).with('sp')
        expect(known_entity).to have_received(:untag_as).with('standalone-aa')
      end
    end

    context 'with an SPSSODescriptor' do
      let(:sp_sso_descriptor) { present_role_descriptor }

      it 'sets the flags' do
        expect(red).to have_received(:update)
          .with(sp: true, idp: false, standalone_aa: false)
      end

      it 'adds the tag' do
        expect(known_entity).to have_received(:tag_as).with('sp')
      end

      it 'removes the other tags' do
        expect(known_entity).to have_received(:untag_as).with('idp')
        expect(known_entity).to have_received(:untag_as).with('aa')
        expect(known_entity).to have_received(:untag_as).with('standalone-aa')
      end
    end

    context 'with an AttributeAuthorityDescriptor' do
      let(:attribute_authority_descriptor) { present_role_descriptor }

      it 'sets the flags' do
        expect(red).to have_received(:update)
          .with(sp: false, idp: false, standalone_aa: true)
      end

      it 'adds the tag' do
        expect(known_entity).to have_received(:tag_as).with('standalone-aa')
      end

      it 'removes the other tags' do
        expect(known_entity).to have_received(:untag_as).with('idp')
        expect(known_entity).to have_received(:untag_as).with('aa')
        expect(known_entity).to have_received(:untag_as).with('sp')
      end
    end

    context 'with an IDPSSODescriptor + AttributeAuthorityDescriptor' do
      let(:idp_sso_descriptor) { present_role_descriptor }
      let(:attribute_authority_descriptor) { present_role_descriptor }

      it 'sets the flags' do
        expect(red).to have_received(:update)
          .with(idp: true, sp: false, standalone_aa: false)
      end

      it 'adds the tags' do
        expect(known_entity).to have_received(:tag_as).with('idp')
        expect(known_entity).to have_received(:tag_as).with('aa')
      end

      it 'removes the other tags' do
        expect(known_entity).to have_received(:untag_as).with('sp')
        expect(known_entity).to have_received(:untag_as).with('standalone-aa')
      end
    end
  end
end
