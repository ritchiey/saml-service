module MDUI
  class Keywords < Sequel::Model
    many_to_one :ui_info

    def validate
      super
      validates_presence :ui_info
      validates_presence :lang
    end

    def to_xml_list
      content
    end

    def add(keyword)
      xml_keyword = keyword.sub ' ', '+'
      (self.content += " #{xml_keyword}") && return if content
      self.content = xml_keyword
    end
  end
end
