module Myhtml::Utils::HtmlEntities
  # !this object never freed!
  HTML_ENTITIES_NODE = Myhtml::Tree.new.create_node(Lib::MyhtmlTags::MyHTML_TAG__TEXT)

  def self.decode(str : String, encoding = Lib::MyEncodingList::MyENCODING_DEFAULT)
    HTML_ENTITIES_NODE.tag_text_set(str, encoding)
    HTML_ENTITIES_NODE.tag_text
  end
end
