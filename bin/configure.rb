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
end

ConfigureCLI.start(ARGV) if __FILE__ == $PROGRAM_NAME
