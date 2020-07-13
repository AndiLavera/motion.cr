module Myhtml
  VERSION = "1.5.1"

  def self.lib_version
    v = Lib.version
    {v.major, v.minor, v.patch}
  end

  def self.version
    "Myhtml v#{VERSION} (libmyhtml v#{lib_version.join('.')})"
  end

  #
  # Decode html entities
  #   Myhtml.decode_html_entities("&#61 &amp; &Auml") # => "= & Ä"
  #
  def self.decode_html_entities(str)
    Utils::HtmlEntities.decode(str)
  end
end

require "./myhtml/lib"
require "./myhtml/*"
