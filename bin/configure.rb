#!/usr/bin/env ruby

require_relative '../config/environment'
require 'thor'

class ConfigureCLI < Thor
  desc 'fr_source [options...]', 'Create or update a Federation Registry source'
  option :hostname, desc: 'The hostname of the Federation Registry instance'
  option :secret, desc: 'The export secret configured in Federation Registry'
  long_desc <<-LONGDESC
    Configures the SAML Service to sync to an upstream Federation Registry using
    the Export API.

    The provided secret will be used to authenticate against the Export API.
  LONGDESC

  def fr_source
    source, other = FederationRegistrySource.all
    fail('Multiple FederationRegistrySource objects exist') if other

    source ||= new_federation_registry_source
    source.update(options.slice(:hostname, :secret))
  end

  desc 'keypair [options...]', 'Create or update a Keypair for metadata signing'
  option :cert, desc: 'The file containing the self-signed certificate'
  option :key, desc: 'The file containing the private key'
  long_desc <<-LONGDESC
    Configures the SAML Service with a keypair which can be used by a metadata
    instance to sign a generated document.

    An existing keypair will be left unmodified. Keypairs are identified by
    the certificate's SHA1 fingerprint.
  LONGDESC

  def keypair
    cert, key = load_keypair
    fingerprint = sha1_fingerprint(cert)
    return if Keypair.first_where(fingerprint: fingerprint)

    Keypair.create(certificate: cert.to_pem, key: key.to_pem,
                   fingerprint: fingerprint)
  end

  desc 'md_instance [options...]', 'Create or update a Metadata Instance'
  option :cert, desc: 'The file containing the metadata certificate'
  option :name, desc: 'The <EntitesDescriptor> name included in the XML'
  option :tag, desc: 'The primary tag for the metadata instance'
  option :hash, desc: 'The hash algorithm for signing (default: SHA256)',
                default: 'SHA256'
  long_desc <<-LONGDESC
    Configures the SAML Service with a metadata instance which will be used to
    generate an output metadata document.

    The primary tag for the created metadata instance will be taken from the
    `tag` option. The provided certificate must have a corresponding `keypair`
    entry already registered.

    Only one metadata instance can be created for each primary tag - any prior
    instance with the same tag will be updated with new configuration.
  LONGDESC
  def md_instance
    instance = MetadataInstance.find_or_new(primary_tag: options[:tag])
    instance.update(md_instance_attrs)
  end

  private

  def new_federation_registry_source
    FederationRegistrySource.new do |source|
      source.entity_source = EntitySource.create(active: true, rank: 10)

      hostname = options[:hostname]
      source.registration_authority = "https://#{hostname}/federationregistry/"
      source.registration_policy_uri = "https://#{hostname}/federationregistry/"
      source.registration_policy_uri_lang = 'en'
    end
  end

  def load_keypair
    [load_certificate, OpenSSL::PKey::RSA.new(File.read(options[:key]))]
  end

  def load_certificate
    OpenSSL::X509::Certificate.new(File.read(options[:cert]))
  end

  def sha1_fingerprint(cert)
    OpenSSL::Digest::SHA1.new(cert.to_der).to_s.downcase
  end

  def md_instance_attrs
    opts = options
    fingerprint = sha1_fingerprint(load_certificate)
    keypair = Keypair.first_where(fingerprint: fingerprint)

    keypair || fail('The provided certificate has not been registered')

    {
      name: opts[:name], federation_identifier: opts[:tag],
      hash_algorithm: opts[:hash].downcase, validity_period: 7.days,
      keypair_id: keypair.id, all_entities: true
    }
  end
end

ConfigureCLI.start(ARGV) if __FILE__ == $PROGRAM_NAME
