class Permission < Sequel::Model
  many_to_one :role

  def validate
    super
    validates_presence [:role, :value]
  end
end
