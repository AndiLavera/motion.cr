class Myhtml::Iterator::Collection
  include ::Iterator(Node)
  include Iterator::Filter

  @id : LibC::SizeT
  @tree : Tree
  @length : LibC::SizeT
  @list : Lib::MyhtmlTreeNodeT**
  @raw_collection : Lib::MyhtmlCollectionT*

  def initialize(@tree, @raw_collection)
    @id = LibC::SizeT.new(0)
    if @raw_collection.null?
      @length = LibC::SizeT.new(0)
      @list = Pointer(Lib::MyhtmlTreeNodeT*).new(0)
    else
      @length = @raw_collection.value.length
      @list = @raw_collection.value.list
    end
    @finalized = false
  end

  def next
    if @id < @length
      node = @list[@id]
      @id += 1
      Node.new(@tree, node)
    else
      stop
    end
  end

  def size
    @length
  end

  def finalize
    free
  end

  def free
    unless @finalized
      @finalized = true
      Lib.collection_destroy(@raw_collection)
    end
  end

  def rewind
    @id = LibC::SizeT.new(0)
  end

  def inspect(io)
    io << "#<Myhtml::Iterator::Collection:0x"
    object_id.to_s(16, io)
    io << ": elements: "

    io << '['

    count = {2, @length}.min
    count.times do |i|
      Node.new(@tree, @list[i]).inspect(io)
      io << ", " unless i == count - 1
    end

    io << ", ...(#{@length - 2} more)" if @length > 2
    io << ']'

    io << '>'
  end
end
