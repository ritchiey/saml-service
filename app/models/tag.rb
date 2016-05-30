# frozen_string_literal: true
class Tag < Sequel::Model
  include Parents
  plugin :validation_helpers
  many_to_one :known_entity

  def validate
    super
    validates_unique([:name, :known_entity])
    validates_presence [:known_entity, :name, :created_at, :updated_at]
  end

  IdP = 'idp'
  AA = 'aa'
  StandaloneAA = 'standalone-aa'
  SP = 'sp'
end
