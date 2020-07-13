struct Myhtml::Node
  #
  # Add attribute to node
  #
  def attribute_add(key : String, value : String, encoding = nil)
    Lib.attribute_add(@raw_node, key, key.bytesize, value, value.bytesize, encoding || @tree.encoding)
    if attrs = @attributes
      attrs[key] = value
    end
    value
  end

  #
  # Remove node attribute by key
  #
  def attribute_remove(key : String)
    Lib.attribute_remove_by_key(@raw_node, key, key.bytesize)
    if attrs = @attributes
      attrs.delete(key)
    end
    key
  end

  #
  # Alias for add, remove attribute
  #   node["class"] = "red"
  #   node["style"] = nil
  #
  def []=(key : String, value : String?)
    if value
      attribute_add(key, value)
    else
      attribute_remove(key)
    end
  end

  #
  # Find attribute by key
  #   iterate over all attributes to find it
  #   if you need to use it multiple times, better to use cached method `attributes[key]?`
  #
  def attribute_by(key : String) : String?
    if attrs = @attributes
      attrs[key]?
    else
      slice = key.to_slice
      each_raw_attribute do |attr|
        if attribute_name(attr) == slice
          return String.new(attribute_value(attr))
        end
      end
      nil
    end
  end

  #
  # Cached Hash(String, String) of attributes
  #   allocated only if you call it
  #
  def attributes
    @attributes ||= begin
      res = {} of String => String
      each_attribute do |k, v|
        res[String.new(k)] = String.new(v)
      end
      res
    end
  end

  def each_attribute(&block)
    each_raw_attribute do |attr|
      yield attribute_name(attr), attribute_value(attr)
    end
  end

  protected def each_raw_attribute(&block)
    attr = Lib.node_attribute_first(@raw_node)
    while !attr.null?
      yield attr
      attr = Lib.attribute_next(attr)
    end
    nil
  end

  @[AlwaysInline]
  private def any_attribute?
    !Lib.node_attribute_first(@raw_node).null?
  end

  @[AlwaysInline]
  private def attribute_name(attr)
    name = Lib.attribute_key(attr, out name_length)
    Slice(UInt8).new(name, name_length)
  end

  @[AlwaysInline]
  private def attribute_value(attr)
    value = Lib.attribute_value(attr, out value_length)
    Slice(UInt8).new(value, value_length)
  end

  def attribute_by(slice : Slice(UInt8))
    each_raw_attribute do |attr|
      if attribute_name(attr) == slice
        return attribute_value(attr)
      end
    end
  end
end
