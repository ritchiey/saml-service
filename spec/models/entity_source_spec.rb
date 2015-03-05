require 'rails_helper'

RSpec.describe EntitySource do
  subject { build(:entity_source) }

  it_behaves_like 'a basic model'

  it { is_expected.to validate_presence(:rank) }
  it { is_expected.to validate_integer(:rank) }
  it { is_expected.to validate_unique(:rank) }
  it { is_expected.to validate_presence(:active) }
  it { is_expected.not_to validate_presence(:url) }
  it { is_expected.not_to validate_presence(:certificate) }

  context 'url validation' do
    it 'accepts a nil url' do
      subject.url = nil
      expect(subject).to be_valid
    end

    it 'accepts a valid https url' do
      subject.url = 'https://fed.example.com/metadata/full.xml'
      expect(subject).to be_valid
    end

    it 'accepts a valid http url' do
      subject.url = 'http://fed.example.com/metadata/full.xml'
      expect(subject).to be_valid
    end

    it 'rejects an ftp url' do
      subject.url = 'ftp://fed.example.com/metadata/full.xml'
      expect(subject).not_to be_valid
    end

    it 'rejects a url which does not parse' do
      subject.url = 'https://fed.test_example.com/metadata/full.xml'
      expect(subject).not_to be_valid
    end
  end

  context 'certificate validation' do
    it 'accepts a nil certificate' do
      subject.certificate = nil
      expect(subject).to be_valid
    end

    it 'accepts a valid certificate' do
      subject.certificate = valid_cert
      expect(subject).to be_valid
    end

    it 'rejects an invalid certificate' do
      subject.certificate = invalid_cert
      expect(subject).not_to be_valid
    end

    it 'rejects a completely invalid string' do
      subject.certificate = 'hello!'
      expect(subject).not_to be_valid
    end
  end

  context '#x509_certificate' do
    it 'returns nil when certificate is nil' do
      subject.certificate = nil
      expect(subject.x509_certificate).to be_nil
    end

    it 'returns a certificate object' do
      subject.certificate = valid_cert
      expect(subject.x509_certificate).to be_an(OpenSSL::X509::Certificate)
    end
  end

  let(:valid_cert) do
    <<-EOF.gsub(/^\s+/, '')
      -----BEGIN CERTIFICATE-----
      MIIDEjCCAfqgAwIBAwIGAUt1eu5UMA0GCSqGSIb3DQEBCwUAMDMxMTAvBgNVBAMM
      KEZvLUhoc1RzaHZNOG1HR25uQXRRaEE2NFNuUnNfMDI3NElFRjdkYnIwHhcNMTUw
      MjEwMjE1MjQ1WhcNMTUwMjEwMjIwMjQ1WjAzMTEwLwYDVQQDDChGby1IaHNUc2h2
      TThtR0dubkF0UWhBNjRTblJzXzAyNzRJRUY3ZGJyMIIBIjANBgkqhkiG9w0BAQEF
      AAOCAQ8AMIIBCgKCAQEA0pyyFLVsbKJpr1MAS5ofZPz1R+uvbq1ySvBPlMRZNsOO
      LxW/YE690xPFcUA47KYZdjHhgUx2lyzPRzARn6gRIR+QY2ujC1g+eEUFth4JSi0/
      KhHoKLm20XYy1k3G11XA8Nh8/IBvZxHIPHl/8UAgr++nGH+6rnWRAEXrha02WXJO
      Tyus6+x6311O8Yw5bP7L3RKjBs1qg8V0NKfDVbjSvohAYWIOZHN3+rCEHcAAhsuZ
      ezX00uzdq29OSGxUx02xxHYpnYacj0PTm5d45HDolRkra7bp9YABOsGHkVC41qn8
      AM8w8yyapqOVHbe1Gu7x66OkKf5yCq9KMBLOAEkxmwIDAQABoywwKjAJBgNVHRME
      AjAAMB0GA1UdDgQWBBSseRpNDC0YSFARQoGwm28iq6MsnjANBgkqhkiG9w0BAQsF
      AAOCAQEAGDD4KhlSl7rzDpu2XUx3/5bvBeybv0b5OsK7XCuwrxBTFlxnp9ilAp4d
      oL6WltlDG9ySiyvjx31AMXKsghTSQcMPUI4noAMUH4XkE0m3sfxuQPY4lBUEaiNB
      gNFst7+HCXQ0Nhmg3mhtNvoilC1l5h2pZyn/X/ZCUb/2cvPIM54PrHUEU760f0R8
      KNeFL5E8z2Jsf0YqmqwboIdWLubCZzyL7uPrNa3lejQnAwILuH7p7fbALuFqlw4R
      PNanaejYZSiFt6WhgEnZFBIQWOm8bIisaDrZDIWDoV95GQ22XwggoQljAgQMcSBF
      GBin3WhsAuXzHCJIuCo1tjvt/O65UQ==
      -----END CERTIFICATE-----
    EOF
  end

  let(:invalid_cert) do
    <<-EOF.gsub(/^\s+/, '')
      -----BEGIN CERTIFICATE-----
      MIIDEjCCAFQGaWibaWigauT1EU5uma0gcsQgsiB3dqebcWuamdmXmtaVbGnvbamm
      kezVluHOC1rZAhznog1hr25UqxrrAee2nfnUuNnFmdi3neLfrJDKyNiWhHCnmtuW
      mJeWmJe1mJq1wHCnmtuWmJeWmJiWmJq1wJaZmteWlWydvqqddcHgBY1iAhnuC2H2
      ttHTr0DUBKf0uwHbnJrtBLjZxZaYnZrjruy3zgjYmiibiJanbGKQHKIg9W0baqef
      aaocaq8amiibcGkcaqea0PYYflvSBkjPR1mas5OFzpZ1r+UVBQ1YsVbpLmrznSoo
      lXw/ye690XpfCua47kyzDJhHGuX2LYZprZarN6Grir+qy2UJc1G+EeufTH4jsI0/
      kHhOklM20xyY1K3g11xa8nH8/ibVzXhiphL/8uaGR++Ngh+6RNwraexRHA02wxjo
      tYUS6+X6311o8yW5Bp7l3rkJbS1QG8v0nkFdvBJsVOHaywiozhn3+RcehCaaHSUz
      EZx00UZDQ29osgXuX02XXhyPNyACJ0ptM5D45hdOLrKRA7BP9yaboSghKvc41QN8
      am8W8YYAPQovhBE1gU7X66oKkF5YcQ9kmbloaeKXMWidaqabOYWWkJajbGnvhrme
      aJaamb0ga1uDdGqwbbsSErPndc0ysfarqOgWM28IQ6mSNJanbGKQHKIg9W0baqSf
      aaocaqeagdd4kHLsL7RZdPU2xuX3/5BVbEYBV0B5oSk7xcUWRXbtfLXNP9ILaP4D
      Ol6wLTLdg9YsIYVJX31amxkSGHtsqCmpui4NOamuh4xKe0M3SFXUqpy4LbueAInb
      GnfST7+hcxq0nHMG3MHTnVOILc1L5H2PzYN/x/zcuB/2CVpim54pRhueu760F0r8
      knEfl5e8Z2jSF0yQMQWBOiDwlUBczZYl7UpRnA3LEJqNaWilUh7P7FBalUfQLW4r
      pnANAEJyzsIfT6wHGeNzfbiqwoM8BiISAdRzdiwdOv95gq22xWGGOqLJaGqmCsbf
      gbIN3wHSaUxZhcjiUcO1TJVT/o65uq==
      -----END CERTIFICATE-----
    EOF
  end
end
