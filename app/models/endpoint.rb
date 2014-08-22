class Endpoint < Sequel::Model
  plugin :class_table_inheritance

  def validate
    super
    uri_regexp = URI.regexp(%w(http https))
    validates_presence [:location, :created_at, :updated_at]
    validates_format uri_regexp, :location
    validates_format uri_regexp, :response_location, allow_nil: true
  end
end
