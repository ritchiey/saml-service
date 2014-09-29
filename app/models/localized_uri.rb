class LocalizedURI < Sequel::Model
  plugin :class_table_inheritance

  def validate
    super
    uri_regexp = URI.regexp(%w(http https))
    validates_presence [:value, :lang, :created_at, :updated_at]
    validates_format uri_regexp, :value
  end
end
