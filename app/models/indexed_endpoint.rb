class IndexedEndpoint < Endpoint
  alias_method :default?, :is_default

  def validate
    super
    validates_presence [:is_default, :index]
  end
end
