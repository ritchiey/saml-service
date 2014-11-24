module MDUI
  class UiInfo < Sequel::Model
    many_to_one :role_descriptor, class: 'RoleDescriptor'

    one_to_one :display_name
    one_to_one :description

    def validate
      super
      validates_presence [:role_descriptor]
    end
  end
end
