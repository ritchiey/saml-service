RSpec.shared_examples 'ds:Signature xml' do
  let(:sig_xpath) { '/*[local-name() = "EntitiesDescriptor"]/ds:Signature' }
  let(:signature) { xml.find(:xpath, sig_xpath) }
  let(:signed_info) { xml.find(:xpath, "#{sig_xpath}/ds:SignedInfo") }
  let(:reference) { signed_info.find(:xpath, 'ds:Reference') }
  let(:key_value) { signature.find(:xpath, 'ds:KeyInfo/ds:KeyValue') }

  it 'has a <Signature> element' do
    expect(xml).to have_xpath("#{sig_xpath}")
  end

  it 'specifies the c14n method' do
    expect(signed_info).to have_xpath('ds:CanonicalizationMethod', count: 1)
  end

  it 'uses the correct c14n method' do
    e = signed_info.find(:xpath, 'ds:CanonicalizationMethod')
    expect(e['Algorithm']).to eq('http://www.w3.org/2001/10/xml-exc-c14n#')
  end

  it 'specifies the signature method' do
    expect(signed_info).to have_xpath('ds:SignatureMethod', count: 1)
  end

  it 'uses the correct signature method' do
    e = signed_info.find(:xpath, 'ds:SignatureMethod')
    expect(e['Algorithm']).to eq('http://www.w3.org/2000/09/xmldsig#rsa-sha1')
  end

  it 'includes the reference element' do
    expect(signed_info).to have_xpath('ds:Reference', count: 1)
  end

  it 'designates the root element to be signed' do
    expect(reference['URI']).to eq("##{subject.instance_id}")
  end

  it 'includes the transforms' do
    expect(reference).to have_xpath('ds:Transforms', count: 1)
    expect(reference).to have_xpath('ds:Transforms/ds:Transform', count: 2)
  end

  it 'specifies the transform algorithms' do
    transforms = reference.all(:xpath, 'ds:Transforms/ds:Transform')
                 .map { |transform| transform['Algorithm'] }
    expect(transforms).to contain_exactly(
      'http://www.w3.org/2000/09/xmldsig#enveloped-signature',
      'http://www.w3.org/2001/10/xml-exc-c14n#'
    )
  end

  it 'includes the digest method' do
    expect(reference).to have_xpath('ds:DigestMethod', count: 1)
  end

  it 'specifies the digest algorithm' do
    e = reference.find(:xpath, 'ds:DigestMethod')
    expect(e['Algorithm']).to eq('http://www.w3.org/2000/09/xmldsig#sha1')
  end

  it 'includes the key info' do
    expect(signature).to have_xpath('ds:KeyInfo', count: 1)
      .and have_xpath('ds:KeyInfo/ds:KeyValue', count: 1)
      .and have_xpath('ds:KeyInfo/ds:X509Data', count: 1)
      .and have_xpath('ds:KeyInfo/ds:X509Data/ds:X509Certificate', count: 1)

    expect(key_value).to have_xpath('ds:RSAKeyValue', count: 1)
      .and have_xpath('ds:RSAKeyValue/ds:Modulus', count: 1)
      .and have_xpath('ds:RSAKeyValue/ds:Exponent', count: 1)
  end

  def bn_base64(bn)
    Base64.strict_encode64([bn.to_s(16)].pack('H*'))
  end

  it 'includes the key modulus' do
    modulus = key_value.find(:xpath, './/ds:Modulus').text
    key = certificate.public_key

    expect(modulus).to eq(bn_base64(key.n))
  end

  it 'includes the key exponent' do
    exponent = key_value.find(:xpath, './/ds:Exponent').text
    key = certificate.public_key

    expect(exponent).to eq(bn_base64(key.e))
  end

  it 'includes the X509 certificate' do
    cert = [
      '-----BEGIN CERTIFICATE-----',
      signature.find(:xpath, './/ds:X509Certificate').text.strip,
      '-----END CERTIFICATE-----'
    ].join("\n")

    expect(cert).to eq(certificate.to_pem.strip)
  end

  context 'with a signed document' do
    let(:schema) { Nokogiri::XML::Schema.new(File.open('schema/top.xsd', 'r')) }
    let(:validation_errors) { schema.validate(Nokogiri::XML.parse(raw_xml)) }
    let(:raw_xml) { subject.sign(key) }

    let(:c14n_xml) do
      doc = subject.builder.doc.dup
      doc.xpath('//ds:Signature').each(&:remove)
      doc.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
    end

    let(:c14n_signed_info) do
      doc = Nokogiri::XML::Document.new
      doc << signed_info.native.dup
      doc.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
    end

    it 'includes the digest value' do
      sha1 = OpenSSL::Digest::SHA1.digest(c14n_xml)
      expected = Base64.strict_encode64(sha1)

      expect(reference.find(:xpath, 'ds:DigestValue').text.strip)
        .to eq(expected)
    end

    it 'includes the signature value' do
      rsa_sig = key.sign(OpenSSL::Digest::SHA1.new, c14n_signed_info)
      expected = Base64.encode64(rsa_sig).strip

      expect(signature.find(:xpath, 'ds:SignatureValue').text.strip)
        .to eq(expected)
    end

    it 'is schema-valid' do
      expect(validation_errors).to be_empty
    end
  end
end
