class CaCertificate < Sequel::Model
  def validate
    super
    validates_presence [:data, :created_at, :updated_at]
  end
end
