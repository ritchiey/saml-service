class Endpoint < Sequel::Model
  plugin :class_table_inheritance

  def validate
    super
    validates_presence [:location, :created_at, :updated_at]
    validates_format %r{https?://[\S]+}, :location
    validates_format %r{https?://[\S]+}, :response_location, allow_nil: true
  end
end
