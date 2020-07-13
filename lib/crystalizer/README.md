# Crystalizer

[![ISC](https://img.shields.io/badge/License-ISC-blue.svg?style=flat-square)](https://en.wikipedia.org/wiki/ISC_license)

[De]serialize any Crystal object - out of the box. Supports JSON, YAML.

## Features

- [De]serialize anything, "out-of-the-box"
- Advanced serialization with annotations, but **not required**
- Shared annotations for all formats (JSON, YAML...)

Implementation bonus: no monkey patching involved :) (no method pollution on objects)

## Installation

Add the dependency to your `shard.yml`:

```yaml
dependencies:
  clicr:
    github: j8r/crystalizer
```

## Documentation

https://j8r.github.io/crystalizer

## Usage

### Basic

```crystal
require "crystalizer/json"
require "crystalizer/yaml"

struct Point
  getter x : Int32
  @[Crystalizer::Field(key: "Y")]
  getter y : String

  def initialize(@x, @y)
  end
end

point = Point.new 1, "a"

{Crystalizer::YAML, Crystalizer::JSON}.each do |format|
  puts format
  string = format.serialize point
  puts string
  puts format.deserialize string, to: Point
end
```

Result:
```
Crystalizer::YAML
---
x: 1
Y: a
Point(@x=1, @y="a")
Crystalizer::JSON
{
  "x": 1,
  "Y": "a"
}
Point(@x=1, @y="a")
```

### Any

Parsing any type, and converting to JSON/YAML.

```cr
require "crystalizer/json"
require "crystalizer/yaml"

yaml_string = <<-E
one: 1
two: 2
sub:
  ary:
  - one
  - 2
E

yaml_any = Crystalizer::YAML.parse yaml_string
puts yaml_any

json_string = Crystalizer::JSON.serialize yaml_any
puts json_string

json_any = Crystalizer::JSON.parse json_string
puts Crystalizer::YAML.serialize json_any
```

Result:
```yaml
{"one" => 1, "two" => 2, "sub" => {"ary" => ["one", 2]}}
{
  "one": 1,
  "two": 2,
  "sub": {
    "ary": [
      "one",
      2
    ]
  }
}
---
one: 1
two: 2
sub:
  ary:
  - one
  - 2
```

### Note

Annotations are similar to the stdlib's `Serializable`, but all features are not yet fully implemented.

## License

Copyright (c) 2020 Julien Reichardt - ISC License
