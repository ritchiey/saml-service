class KeyDescriptor < Sequel::Model
  many_to_one :key_type
  many_to_one :key_info
  one_to_many :encryption_method

  def validate
    super
    validates_presence [:key_type, :key_info, :created_at, :updated_at]
  end

  def type
    key_type.use
  end
end
