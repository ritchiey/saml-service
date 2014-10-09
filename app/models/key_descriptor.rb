class KeyDescriptor < Sequel::Model
  many_to_one :key_info
  one_to_many :encryption_method

  many_to_one :role_descriptor

  KEY_TYPE = { encryption: 0, signing: 1 }

  def key_type
    KEY_TYPE.key(key_type_id)
  end

  def key_type=(use)
    self.key_type_id = KEY_TYPE[use]
  end

  def validate
    super
    validates_presence [:key_type_id, :key_type, :created_at, :updated_at]
    validates_presence :key_info, allow_missing: new?
    validates_includes [:encryption, :signing], :key_type
  end
end
