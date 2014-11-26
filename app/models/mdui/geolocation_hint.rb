module MDUI
  class GeolocationHint < Sequel::Model
    many_to_one :disco_hints

    def validate
      super
      validates_presence [:disco_hints, :uri, :created_at, :updated_at]
    end
  end
end
