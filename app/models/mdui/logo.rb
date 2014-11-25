module MDUI
  class Logo < LocalizedURI
    many_to_one :ui_info

    def validate
      super
      validates_presence :ui_info

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
