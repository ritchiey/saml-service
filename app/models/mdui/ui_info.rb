module MDUI
  class UiInfo < Sequel::Model
    many_to_one :role_descriptor, class: 'RoleDescriptor'

    def validate
      super
      validates_presence [:role_descriptor]
    end
  end
end
