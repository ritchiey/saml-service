module MDUI
  class Logo < Sequel::Model
    many_to_one :ui_info

    def validate
      super
      uri_regexp = URI.regexp(%w(http https))
      validates_presence [:ui_info, :uri, :created_at, :updated_at]
      validates_format uri_regexp, :uri

      validate_width
      validate_height
    end

    private

    def validate_width
      errors.add(:width, 'must specify pixels') unless width && width > 0
    end

    def validate_height
      errors.add(:height, 'must specify pixels') unless height && height > 0
    end
  end
end
