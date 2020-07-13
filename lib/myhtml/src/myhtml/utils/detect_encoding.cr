module Myhtml::Utils::DetectEncoding
  record EncodingNotFound, encoding : String

  #
  # Detect encoding from header
  #   example:
  #     Myhtml::Utils::DetectEncoding.from_header(headers["Content-Type"]) # => MyHTML_ENCODING_WINDOWS_1251
  #     Myhtml::Utils::DetectEncoding.from_header("text/html; charset=Windows-1251") # => MyHTML_ENCODING_WINDOWS_1251
  #
  def self.from_header(header : String) : Lib::MyEncodingList | EncodingNotFound
    res = Lib.encoding_extracting_character_encoding_from_charset_with_found(header, header.bytesize, out e, out pointer, out bytesize)
    if res
      e
    else
      EncodingNotFound.new(String.new(pointer, bytesize))
    end
  end

  def self.from_header?(header) : Lib::MyEncodingList?
    enc = from_header(header)
    if enc.is_a?(Lib::MyEncodingList)
      enc
    end
  end

  #
  # Detect encoding from meta tag in content
  #   example:
  #     Myhtml::Utils::DetectEncoding.from_meta(content) # => MyHTML_ENCODING_WINDOWS_1251
  #     Myhtml::Utils::DetectEncoding.from_meta(%Q{ <meta http-equiv="Content-Type" content="text/html; charset=windows-1251" />}) # => MyHTML_ENCODING_WINDOWS_1251
  #
  def self.from_meta(content : String)
    from_meta(content.to_unsafe, content.bytesize)
  end

  def self.from_meta(pointer, bytesize)
    enc = Lib.encoding_prescan_stream_to_determine_encoding_with_found(pointer, bytesize, out pointer2, out bytesize2)
    if enc != Lib::MyEncodingList::MyENCODING_NOT_DETERMINED
      enc
    else
      EncodingNotFound.new(String.new(pointer2, bytesize2))
    end
  end

  def self.from_meta?(content : String)
    from_meta?(content.to_unsafe, content.bytesize)
  end

  def self.from_meta?(pointer, bytesize)
    enc = from_meta(pointer, bytesize)
    if enc.is_a?(Lib::MyEncodingList)
      enc
    end
  end

  #
  # Detects encoding by trigrams
  #   slow and not 100% correct
  #
  def self.detect(content : String)
    detect?(content)
  end

  def self.detect(pointer, bytesize)
    detect?(pointer, bytesize)
  end

  def self.detect?(content : String)
    detect?(content.to_unsafe, content.bytesize)
  end

  def self.detect?(pointer, bytesize)
    if Lib.encoding_detect(pointer, bytesize, out enc)
      enc
    end
  end
end
