class CaKeyInfo < KeyInfo
  many_to_one :entities_descriptor

  def validate
    super
    validates_presence [:entities_descriptor]
  end
end
