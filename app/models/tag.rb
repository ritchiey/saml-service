class Tag < Sequel::Model
  def validate
    validates_presence [:name, :created_at, :updated_at]
  end
end
