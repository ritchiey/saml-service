require 'implicit_schema'
require 'sequel'

class UpdateFromFederationRegistry
  include QueryFederationRegistry
  include StoreFederationRegistryData

  include ETL::Contacts
  include ETL::Organizations
  include ETL::EntityDescriptors
  include ETL::IdentityProviders

  attr_reader :fr_source, :source, :primary_tag

  def self.perform(id, primary_tag)
    new(id, primary_tag).perform
  end

  def initialize(id, primary_tag)
    @cache = {}
    @fr_source = FederationRegistrySource[id]
    @source = @fr_source.entity_source
    @primary_tag = primary_tag
  end

  def perform
    Sequel::Model.db.transaction do
      contacts
      organizations
    end

    true
  end
end
