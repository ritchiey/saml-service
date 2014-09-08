class KeyType < Sequel::Model
  USE = { encryption: 0, signing: 1 }

  def use
    USE.key(super)
  end

  def use=(t)
    super USE[t]
  end

  def validate
    super
    validates_presence [:use, :created_at, :updated_at]
    validates_includes USE.keys, :use
  end
end
