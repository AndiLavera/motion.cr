struct Myhtml::Node
  #
  # Convert node to html string
  #   **deep** - option, means visit children nodes or not (by default true).
  #
  # Example:
  # ```
  # parser = Myhtml::Parser.new("<html><body><div class=AAA style='color:red'>Haha <span>11</span></div></body></html>")
  # node = parser.nodes(:div).first
  # node.to_html              # => `<div class="AAA" style="color:red">Haha <span>11</span></div>`
  # node.to_html(deep: false) # => `<div class="AAA" style="color:red">`
  # ```
  #
  def to_html(deep = true)
    str = Lib::MyhtmlStringRawT.new

    Lib.string_raw_clean_all(pointerof(str))

    res = if deep
            Lib.serialization(@raw_node, pointerof(str))
          else
            Lib.serialization_node(@raw_node, pointerof(str))
          end

    if res == Lib::MyStatus::MyCORE_STATUS_OK
      res = String.new(str.data, str.length)
      Lib.string_raw_destroy(pointerof(str), false)
      res
    else
      Lib.string_raw_destroy(pointerof(str), false)
      raise LibError.new("Unknown problem with serialization: #{res}")
    end
  end

  #
  # Convert node to html to IO
  #   **deep** - option, means visit children nodes or not (by default true).
  #
  def to_html(io : IO, deep = true)
    iow = IOWrapper.new(io)

    if deep
      Lib.serialization_tree_callback(@raw_node, SERIALIZE_CALLBACK, iow.as(Void*))
    else
      Lib.serialization_node_callback(@raw_node, SERIALIZE_CALLBACK, iow.as(Void*))
    end
  end

  #
  # Convert node to html string, with formatting
  #
  def to_pretty_html(io : IO)
    _to_html_nodes(io, 0, true)
  end

  #
  # Convert node to html string, with formatting
  #
  def to_pretty_html
    String.build { |io| _to_html_nodes(io, 0, true) }
  end

  # :nodoc:
  protected def _to_html_nodes(io, level = 0, rooted = false)
    case _tag_id = tag_id
    when Lib::MyhtmlTags::MyHTML_TAG__TEXT
      _format_text(io, level)
    when Lib::MyhtmlTags::MyHTML_TAG__COMMENT
      _format_add_spaces(io, level)
      io << "<!--"
      _format_text(io, level + 1, false)
      io << "-->"
      true
    when Lib::MyhtmlTags::MyHTML_TAG__UNDEF
      ch = child
      c = 0
      while ch
        ch._to_html_nodes(io, level, c == 0)
        ch = ch.next
        c += 1
      end
      true
    else
      _format_add_spaces(io, level, !rooted)
      to_html(io, false)

      return true if void_element? || _tag_id == Lib::MyhtmlTags::MyHTML_TAG__DOCTYPE

      ch = child
      written_something = false
      while ch
        written_something |= ch._to_html_nodes(io, level + 1)
        ch = ch.next
      end

      _format_add_spaces(io, level) if written_something
      to_html_end(io)

      true
    end
  end

  # :nodoc:
  protected def _format_text(io, level = 0, start_with_newline = true)
    buf = tag_text_slice

    i = 0
    j = 0
    writed = false
    start_new_line = start_with_newline
    while i = buf.index('\n'.ord.to_u8, j)
      slice = buf[j, i - j]
      if _write_formatted_slice(io, slice, level, start_new_line)
        writed = true
        start_new_line = true
      end
      j = i + 1
    end

    if j < buf.bytesize - 1
      slice = buf[j, buf.bytesize - j]
      if _write_formatted_slice(io, slice, level, start_new_line)
        writed = true
      end
    end

    writed
  end

  # :nodoc:
  protected def _write_formatted_slice(io, slice, level, start_new_line)
    slice2 = Myhtml::Utils::Strip.strip_slice(slice)

    if slice2.bytesize > 0
      _format_add_spaces(io, level) if start_new_line
      io.write(slice2)
      true
    end
  end

  # :nodoc:
  private def _format_add_spaces(io, level, newline = true)
    io << '\n' if newline
    (level * 2).times { io << ' ' }
  end

  #
  # Convert end of tag to string
  #   ex: node.to_html_end # => "</div>"
  def to_html_end
    String.build { |io| to_html_end(io) }
  end

  # :nodoc:
  def to_html_end(io)
    io << "</"
    io.write(tag_name_slice)
    io << '>'
  end

  # :nodoc:
  private class IOWrapper
    def initialize(@io : IO)
    end

    def write(b : Bytes)
      @io.write(b)
    end
  end

  # :nodoc:
  SERIALIZE_CALLBACK = ->(text : UInt8*, length : LibC::SizeT, data : Void*) do
    data.as(IOWrapper).write(Bytes.new(text, length))
    Lib::MyStatus::MyCORE_STATUS_OK
  end
end
