module MDUI
  class UIInfo < Sequel::Model
    many_to_one :role_descriptor, class: 'RoleDescriptor'

    one_to_many :display_names
    one_to_many :descriptions
    one_to_many :keyword_lists
    one_to_many :logos
    one_to_many :information_urls
    one_to_many :privacy_statement_urls

    def validate
      super
      validates_presence [:role_descriptor, :created_at, :updated_at]
      return if new?

      validates_presence [:display_names, :descriptions]
    end
  end
end
