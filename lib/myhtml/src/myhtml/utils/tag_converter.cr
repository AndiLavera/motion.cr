module Myhtml::Utils::TagConverter
  def self.sym_to_id(sym : Symbol)
    {% begin %}
    case sym
    {% for name in Lib::MyhtmlTags.constants %}
      when :{{ name.gsub(/MyHTML_TAG_/, "").downcase.id }}
        Lib::MyhtmlTags::{{ name.id }}
    {% end %}
    else
      raise ArgumentError.new("Unknown tag #{sym.inspect}")
    end
    {% end %}
  end

  def self.id_to_sym(tag_id : Lib::MyhtmlTags)
    {% begin %}
    case tag_id
    {% for name in Lib::MyhtmlTags.constants %}
      when Lib::MyhtmlTags::{{ name.id }}
        :{{ name.gsub(/MyHTML_TAG_/, "").downcase.id }}
    {% end %}
    else
      :unknown
    end
    {% end %}
  end

  STRING_TO_SYM_MAP = begin
    h = Hash(String, Symbol).new
    {% for name in Lib::MyhtmlTags.constants.map(&.gsub(/MyHTML_TAG_/, "").downcase) %}
      h["{{ name.id }}"] = :{{ name.id }}
    {% end %}
    h
  end

  STRING_TO_ID_MAP = begin
    h = Hash(String, Lib::MyhtmlTags).new
    {% for name in Lib::MyhtmlTags.constants %}
      h["{{ name.gsub(/MyHTML_TAG_/, "").downcase.id }}"] = Lib::MyhtmlTags::{{ name.id }}
    {% end %}
    h
  end

  def self.string_to_sym(str : String)
    STRING_TO_SYM_MAP.fetch(str) { raise ArgumentError.new("Unknown tag #{str.inspect}") }
  end

  def self.string_to_id(str : String)
    STRING_TO_ID_MAP.fetch(str) { raise ArgumentError.new("Unknown tag #{str.inspect}") }
  end
end
