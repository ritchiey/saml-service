class Role < Sequel::Model
  one_to_many :permissions

  def validate
    super
    validates_presence [:name]
  end
end
