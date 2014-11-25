module MDUI
  class UiInfo < Sequel::Model
    many_to_one :role_descriptor, class: 'RoleDescriptor'

    one_to_many :display_name
    one_to_many :description
    one_to_many :keywords
    one_to_many :logos

    def validate
      super
      validates_presence [:role_descriptor]
    end
  end
end
