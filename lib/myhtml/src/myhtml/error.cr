# Exception for errors raised by this shard.
class Myhtml::Error < Exception
end

# Raised when trying to enter not exist node
class Myhtml::EmptyNodeError < Myhtml::Error
end

# Raised when unexpected input
class Myhtml::ArgumentError < Myhtml::Error
end

# Raised when myhtml library return bad status
class Myhtml::LibError < Myhtml::Error
end
