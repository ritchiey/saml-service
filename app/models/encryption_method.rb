class EncryptionMethod < Sequel::Model
  many_to_one :key_descriptor

  def validate
    super
    validates_presence [:key_descriptor, :algorithm, :created_at, :updated_at]
  end
end
