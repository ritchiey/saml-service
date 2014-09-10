class Organization < Sequel::Model
  def validate
    super
    validates_presence [:name, :display_name, :url, :created_at, :updated_at]
  end
end
