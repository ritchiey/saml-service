class Contact < Sequel::Model
  def validate
    super
    validates_presence [:created_at, :updated_at]
  end
end
