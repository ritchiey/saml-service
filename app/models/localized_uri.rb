# frozen_string_literal: true
class LocalizedURI < Sequel::Model
  plugin :class_table_inheritance

  def validate
    super
    uri_regexp = URI.regexp(%w(http https))
    validates_presence [:uri, :lang, :created_at, :updated_at]
    validates_format uri_regexp, :uri
  end
end
