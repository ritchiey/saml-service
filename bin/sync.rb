#!/usr/bin/env ruby

require_relative '../config/environment'

class SyncCLI
  def self.perform(tag)
    FederationRegistrySource.each do |fr_source|
      UpdateFromFederationRegistry.perform(id: fr_source.id, primary_tag: tag)
    end
  end
end

SyncCLI.perform(*ARGV) if __FILE__ == $PROGRAM_NAME
