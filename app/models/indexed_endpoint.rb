# frozen_string_literal: true
class IndexedEndpoint < Endpoint
  alias default? is_default

  def validate
    super
    validates_presence [:is_default, :index]
  end
end
