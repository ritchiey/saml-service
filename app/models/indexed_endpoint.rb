class IndexedEndpoint < Endpoint
  def validate
    super
    validates_presence [:is_default, :index]
  end
end
