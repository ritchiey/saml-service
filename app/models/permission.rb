class Permission < Sequel::Model
  many_to_one :role

  def validate
    super
    validates_presence [:role, :value]
    validates_format Accession::Permission.regexp, :value
    validates_unique [:value, :role_id]
  end
end
