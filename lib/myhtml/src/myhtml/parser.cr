struct Myhtml::Parser
  # :nodoc:
  getter tree : Tree

  #
  # Parse html from string
  # example: myhtml = Myhtml::Parser.new("<html>...</html>", encoding: Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251)
  #
  # Options:
  #   **encoding** - set encoding of html (see list of encodings in Myhtml::Lib::MyEncodingList), by default it parsed as UTF-8
  #   **detect_encoding_from_meta** - try to find encoding from meta tag in the html (<meta charset=...>)
  #   **detect_encoding** - detect encoding by slow trigrams algorithm
  #   **tree_options** - additional myhtml options for parsing (see Myhtml::Lib::MyhtmlTreeParseFlags)
  #

  def self.new(page : String,
               encoding : Lib::MyEncodingList? = nil,
               detect_encoding_from_meta : Bool = false,
               detect_encoding : Bool = false,
               tree_options : Lib::MyhtmlTreeParseFlags? = nil)
    self.new(tree_options: tree_options,
      encoding: encoding,
      detect_encoding_from_meta: detect_encoding_from_meta,
      detect_encoding: detect_encoding).parse(page)
  end

  #
  # Parse html from IO
  # example: myhtml = Myhtml::Parser.new(io, encoding: Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251)
  #
  # Options:
  #   **encoding** - set encoding of html (see list of encodings in Myhtml::Lib::MyEncodingList), by default it parsed as UTF-8
  #   **tree_options** - additional myhtml options for parsing (see Myhtml::Lib::MyhtmlTreeParseFlags)
  #

  def self.new(io : IO,
               tree_options : Lib::MyhtmlTreeParseFlags? = nil,
               encoding : Lib::MyEncodingList? = nil)
    self.new(tree_options: tree_options, encoding: encoding).parse_stream(io)
  end

  #
  # Root nodes for parsed tree
  #   **myhtml.body!** - body node
  #   **myhtml.head!** - head node
  #   **myhtml.root!** - html node
  #   **myhtml.document!** - document node
  #
  delegate :body, :body!, :head, :head!, :root, :root!, :html, :html!, :document!, to: tree

  #
  # Top level node filter (select all nodes in tree with tag_sym)
  #   returns Myhtml::Iterator::Collection
  #   equal with myhtml.root!.scope.nodes(...)
  #
  #   myhtml.nodes(:div).each { |node| ... }
  #
  delegate :nodes, to: tree

  #
  # Css selectors, see Node#css
  #
  delegate :css, to: document!

  #
  # Convert html tree to html string, see Node#to_html
  #
  delegate :to_html, to: document!
  delegate :to_pretty_html, to: document!

  #
  # Manually free object, dangerous (also called by GC finalize)
  #
  delegate :free, to: tree

  #
  # Current encoding
  #
  delegate :encoding, to: tree

  # :nodoc:
  protected def initialize(tree_options : Lib::MyhtmlTreeParseFlags? = nil,
                           encoding : Lib::MyEncodingList? = nil,
                           @detect_encoding_from_meta : Bool = false,
                           @detect_encoding : Bool = false)
    @tree = Tree.new(encoding || Lib::MyEncodingList::MyENCODING_DEFAULT)
    @tree.set_flags(tree_options) if tree_options
  end

  # :nodoc:
  protected def parse(string)
    pointer = string.to_unsafe
    bytesize = string.bytesize

    if Lib.encoding_detect_and_cut_bom(pointer, bytesize, out encoding2, out pointer2, out bytesize2)
      pointer = pointer2
      bytesize = bytesize2
      @tree.encoding = encoding2
    else
      detected = false

      if @detect_encoding_from_meta
        if enc = Utils::DetectEncoding.from_meta?(pointer, bytesize)
          detected = true
          @tree.encoding = enc
        end
      end

      if @detect_encoding && !detected
        if enc = Utils::DetectEncoding.detect?(pointer, bytesize)
          @tree.encoding = enc
        end
      end
    end

    res = Lib.parse(@tree.raw_tree, @tree.encoding, pointer, bytesize)
    if res != Lib::MyStatus::MyCORE_STATUS_OK
      free
      raise LibError.new("parse error #{res}")
    end

    self
  end

  # :nodoc:
  BUFFER_SIZE = 8192

  # :nodoc:
  protected def parse_stream(io : IO)
    buffers = Array(Bytes).new
    Lib.encoding_set(@tree.raw_tree, @tree.encoding)

    loop do
      buffer = Bytes.new(BUFFER_SIZE)
      read_size = io.read(buffer)
      break if read_size == 0

      buffers << buffer
      res = Lib.parse_chunk(@tree.raw_tree, buffer, read_size)
      if res != Lib::MyStatus::MyCORE_STATUS_OK
        free
        raise LibError.new("parse_chunk error #{res}")
      end
    end

    res = Lib.parse_chunk_end(@tree.raw_tree)
    if res != Lib::MyStatus::MyCORE_STATUS_OK
      free
      raise LibError.new("parse_chunk_end error #{res}")
    end

    self
  end
end
