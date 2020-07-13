struct Myhtml::Node
  # :nodoc:
  def self_closed?
    Lib.node_is_close_self(@raw_node)
  end

  # :nodoc:
  def void_element?
    Lib.node_is_void_element(@raw_node)
  end

  def textable?
    case tag_id
    when Lib::MyhtmlTags::MyHTML_TAG__TEXT,
         Lib::MyhtmlTags::MyHTML_TAG__COMMENT,
         Lib::MyhtmlTags::MyHTML_TAG_STYLE
      true
    else
      false
    end
  end

  def visible?
    case tag_id
    when Lib::MyhtmlTags::MyHTML_TAG_STYLE,
         Lib::MyhtmlTags::MyHTML_TAG__COMMENT,
         Lib::MyhtmlTags::MyHTML_TAG_SCRIPT,
         Lib::MyhtmlTags::MyHTML_TAG_HEAD
      false
    else
      true
    end
  end

  def object?
    case tag_id
    when Lib::MyhtmlTags::MyHTML_TAG_APPLET,
         Lib::MyhtmlTags::MyHTML_TAG_IFRAME,
         Lib::MyhtmlTags::MyHTML_TAG_FRAME,
         Lib::MyhtmlTags::MyHTML_TAG_FRAMESET,
         Lib::MyhtmlTags::MyHTML_TAG_EMBED,
         Lib::MyhtmlTags::MyHTML_TAG_OBJECT
      true
    else
      false
    end
  end

  {% for name in Lib::MyhtmlTags.constants %}
    def is_tag_{{ name.gsub(/MyHTML_TAG_/, "").downcase.id }}?
      tag_id == Lib::MyhtmlTags::{{ name.id }}
    end
  {% end %}

  def is_text?
    tag_id == Lib::MyhtmlTags::MyHTML_TAG__TEXT
  end

  def is_tag_noindex?
    tag_id >= Lib::MyhtmlTags::MyHTML_TAG_LAST_ENTRY && tag_name_slice == "noindex".to_slice
  end

  def is_tag_nofollow?
    tag_id >= Lib::MyhtmlTags::MyHTML_TAG_LAST_ENTRY && tag_name_slice == "nofollow".to_slice
  end
end
