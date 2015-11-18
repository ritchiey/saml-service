#!/usr/bin/env ruby

require_relative '../config/environment'

class SyncCLI
  def self.perform(hostname, tag)
    fr_source = FederationRegistrySource[hostname: hostname]
    UpdateFromFederationRegistry.perform(id: fr_source.id, primary_tag: tag)
  end
end

SyncCLI.perform(*ARGV) if __FILE__ == $PROGRAM_NAME
