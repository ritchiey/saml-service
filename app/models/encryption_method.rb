class EncryptionMethod < Sequel::Model
  def validate
    super
    validates_presence [:algorithm, :created_at, :updated_at]
  end
end
