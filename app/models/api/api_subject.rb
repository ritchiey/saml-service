module API
  class APISubject < Sequel::Model
    include Accession::Principal

    def permissions
      # This should be extended to gather permissions from role membership
      # and any other data sources providing input to api_subject identity
      []
    end

    def validate
      validates_presence [:x509_dn, :created_at, :updated_at]
    end
  end
end
