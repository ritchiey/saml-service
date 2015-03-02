module Metadata
  module Schema
    def metadata_schema
      Nokogiri::XML::Schema.new(file.open)
    end

    private

    def file
      Rails.root.join('schema', 'top.xsd')
    end
  end
end
