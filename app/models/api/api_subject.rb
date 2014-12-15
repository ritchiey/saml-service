module API
  class APISubject < Sequel::Model
    include Accession::Principal

    many_to_many :roles, class: 'Role'

    def permissions
      # This should be extended to gather permissions from role membership
      # and any other data sources providing input to api_subject identity
      roles.flat_map { |role| role.permissions.map(&:value) }
    end

    def validate
      validates_presence [:x509_dn, :created_at, :updated_at]
    end
  end
end
