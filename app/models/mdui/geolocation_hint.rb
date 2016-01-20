module MDUI
  class GeolocationHint < Sequel::Model
    many_to_one :disco_hints

    def validate
      super
      validates_presence [:disco_hints, :uri, :created_at, :updated_at]
    end

    def latitude
      uri_parts[0]
    end

    def longitude
      uri_parts[1]
    end

    def altitude
      uri_parts[2]
    end

    private

    def uri_parts
      @uri_parts ||= URI.parse(uri).opaque.split(',', 3)
    end
  end
end
