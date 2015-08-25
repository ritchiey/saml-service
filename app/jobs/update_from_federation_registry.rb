require 'implicit_schema'
require 'sequel'

class UpdateFromFederationRegistry
  include QueryFederationRegistry
  include StoreFederationRegistryData

  attr_reader :fr_source, :source

  def self.perform(id)
    new(id).perform
  end

  def initialize(id)
    @cache = {}
    @fr_source = FederationRegistrySource[id]
    @source = @fr_source.entity_source
  end

  def perform
    Sequel::Model.db.transaction do
      fr_organizations.each do |org|
        organization(org[:organization])
      end
    end
  end

  include ETL::Organizations

  # TODO: migrate to ETL::EntityDescriptors
  def entity_descriptor(_o, _org_data)
  end
end
