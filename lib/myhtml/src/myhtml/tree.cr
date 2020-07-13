class Myhtml::Tree
  # :nodoc:
  property encoding : Lib::MyEncodingList

  # :nodoc:
  getter raw_tree : Lib::MyhtmlTreeT*

  # :nodoc:
  def initialize(@encoding = Lib::MyEncodingList::MyENCODING_DEFAULT)
    options = Lib::MyhtmlOptions::MyHTML_OPTIONS_PARSE_MODE_SINGLE
    threads_count = 1
    queue_size = 0

    @raw_myhtml = Lib.create
    res = Lib.init(@raw_myhtml, options, threads_count, queue_size)
    if res != Lib::MyStatus::MyCORE_STATUS_OK
      raise LibError.new("init error #{res}")
    end

    @raw_tree = Lib.tree_create
    res = Lib.tree_init(@raw_tree, @raw_myhtml)

    if res != Lib::MyStatus::MyCORE_STATUS_OK
      Lib.destroy(@raw_myhtml)
      raise LibError.new("tree_init error #{res}")
    end

    @finalized = false
  end

  # :nodoc:
  def set_flags(flags : Lib::MyhtmlTreeParseFlags)
    Lib.tree_parse_flags_set(@raw_tree, flags)
  end

  #
  # Root nodes for tree
  #   **myhtml.body!** - body node
  #   **myhtml.head!** - head node
  #   **myhtml.root!** - html node
  #   **myhtml.document!** - document node
  #
  {% for name in %w(head body html root) %}
    def {{ name.id }}
      Node.from_raw(self, Lib.tree_get_node_{{(name == "root" ? "html" : name).id}}(@raw_tree))
    end

    def {{ name.id }}!
      if val = {{ name.id }}
        val
      else
        raise EmptyNodeError.new("expected `{{name.id}}` to present on myhtml tree")
      end
    end
  {% end %}

  def document!
    if node = Node.from_raw(self, Lib.tree_get_document(@raw_tree))
      node
    else
      raise EmptyNodeError.new("expected document to present on myhtml tree")
    end
  end

  # :nodoc:
  def undefined_root!
    root!.parent!
  end

  #
  # Top level node filter (select all nodes in tree with tag_id)
  #   returns Myhtml::Iterator::Collection
  #   equal with myhtml.root!.scope.nodes(...)
  #
  #   myhtml.nodes(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_DIV).each { |node| ... }
  #
  def nodes(tag_id : Myhtml::Lib::MyhtmlTags)
    Iterator::Collection.new(self, Lib.get_nodes_by_tag_id(@raw_tree, nil, tag_id, out status))
  end

  #
  # Top level node filter (select all nodes in tree with tag_sym)
  #   returns Myhtml::Iterator::Collection
  #   equal with myhtml.root!.scope.nodes(...)
  #
  #   myhtml.nodes(:div).each { |node| ... }
  #
  def nodes(tag_sym : Symbol)
    nodes(Utils::TagConverter.sym_to_id(tag_sym))
  end

  #
  # Top level node filter (select all nodes in tree with tag_sym)
  #   returns Myhtml::Iterator::Collection
  #   equal with myhtml.root!.scope.nodes(...)
  #
  #   myhtml.nodes("div").each { |node| ... }
  #
  def nodes(tag_str : String)
    nodes(Utils::TagConverter.string_to_id(tag_str))
  end

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
  # Create a new node
  #
  # **Note**: this does not add the node to any document or tree. It only
  # creates the object that can then be appended or inserted. See
  # `Node#append_child`, `Node#insert_after`, and `Node#insert_before`
  #
  # ```crystal
  # tree = Myhtml::Tree.new
  # div = tree.create_node(:div)
  # a = tree.create_node(:a)
  #
  # div.to_html # <div></div>
  # a.to_html   # <a></a>
  # ```
  #
  def create_node(tag_id : Myhtml::Lib::MyhtmlTags)
    raw_node = Lib.node_create(raw_tree, tag_id, Myhtml::Lib::MyhtmlNamespace::MyHTML_NAMESPACE_HTML)
    if node = Node.from_raw(self, raw_node)
      node
    else
      raise EmptyNodeError.new("unable to create node")
    end
  end

  def create_node(tag_sym : Symbol)
    create_node(Utils::TagConverter.sym_to_id(tag_sym))
  end

  def create_node(tag_name : String)
    create_node(Utils::TagConverter.string_to_id(tag_name))
  end

  #
  # Manually free object, dangerous (also called by GC finalize)
  #
  def free
    unless @finalized
      @finalized = true
      Lib.tree_destroy(@raw_tree)
      Lib.destroy(@raw_myhtml)
    end
  end

  # :nodoc:
  def finalize
    free
  end
end
