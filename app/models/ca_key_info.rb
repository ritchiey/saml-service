class CaKeyInfo < Sequel::Model
  # Strictly this model should be
  # CaKeyInfo has_a CaCertificate
  # However by modelling as we have we reduce validation complexity and
  # problems with Sequel not being able to adequately perform cascading saves
  # where models are 1:1 and require reciprocal presence validation
  def validate
    super
    validates_presence [:data, :created_at, :updated_at]
  end
end
