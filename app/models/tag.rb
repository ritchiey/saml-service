class Tag < Sequel::Model
  include Parents
  plugin :validation_helpers
  many_to_one :known_entity

  def validate
    super
    validates_unique([:name, :known_entity])
    validates_presence [:known_entity, :name, :created_at, :updated_at]
  end

  IdP = 'idp'.freeze
  AA = 'aa'.freeze
  StandaloneAA = 'standalone-aa'.freeze
  SP = 'sp'.freeze
end
