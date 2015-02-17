class EntitySource < Sequel::Model
  def validate
    super
    validates_presence [:rank, :active, :created_at, :updated_at]
    validates_integer :rank
    validates_unique :rank
  end
end
