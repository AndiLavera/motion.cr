require "./spec_helper"

describe Myhtml::Node do
  it "select_tags" do
    parser = Myhtml::Parser.new("<html><body><div class=AAA style='color:red'>Haha</div>
      <div>blah</div>
      </body></html>")

    parser.nodes(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_DIV).size.should eq 2
    parser.nodes(:div).size.should eq 2
    parser.nodes("div").size.should eq 2
    nodes = parser.nodes(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_DIV).to_a
    nodes.size.should eq 2

    node1, node2 = nodes
    node1.child!.tag_text.should eq "Haha"
    node2.child!.tag_text.should eq "blah"

    nodes = parser.nodes(:div).to_a
    nodes.size.should eq 2
  end

  it "each_tag" do
    parser = Myhtml::Parser.new("<html><body><div class=AAA style='color:red'>Haha</div>
      <div>blah</div>
      </body></html>")

    nodes = [] of Myhtml::Node
    parser.nodes(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_DIV).each { |n| nodes << n }
    nodes.size.should eq 2

    node1, node2 = nodes
    node1.child!.tag_text.should eq "Haha"
    node2.child!.tag_text.should eq "blah"

    nodes = [] of Myhtml::Node
    parser.nodes(:div).each { |n| nodes << n }
    nodes.size.should eq 2
  end

  it "correctly works with unicode" do
    str = <<-HTML
      <html>
      <head>
        <meta name="keywords" content="аа, ааааааааааа, ааааааааа, ааа, ааааааа, ааааааааа"  />
      </head>

      <body id='normal' >
        <a href="http://aaaa-aaa.ru/">#</a>
      </body></html>
    HTML

    parser = Myhtml::Parser.new(str)
    parser.nodes(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_A).size.should eq 1
    parser.nodes(:a).size.should eq 1
    parser.nodes("a").size.should eq 1
  end

  it "parse html with bom" do
    slice = Slice.new(3, 0_u8)
    slice[0] = 0xef.to_u8
    slice[1] = 0xbb.to_u8
    slice[2] = 0xbf.to_u8
    str = String.new(slice)
    str += "<html><head><title>1</title></head></html>"

    parser = Myhtml::Parser.new(str)

    title = parser.head!.child!
    title.tag_name.should eq "title"
    title.child.try(&.tag_text).should eq "1"
  end

  it "manually call free, to save memory" do
    10000.times do
      parser = Myhtml::Parser.new("<html><body><div class=AAA style='color:red'>Haha</div>
        <div>blah</div>
        </body></html>")
      parser.free
    end
  end

  it "raise when non supported tag name is given by String" do
    parser = Myhtml::Parser.new("<html></html>")
    expect_raises(Myhtml::Error, /Unknown tag "xxx"/) { parser.nodes("xxx") }
  end

  it "not sigfaulting on more than 1024 elements" do
    str = "<html>" + "<div class=A>ooo</div>" * 2000 + "</html>"
    parser = Myhtml::Parser.new(str)

    c = 0
    parser.nodes(:div).each do |node|
      c += 1 if node.attribute_by("class") == "A"
    end
    c.should eq 2000
  end

  it "parse_stream" do
    str = "<html><body>" + "<div class=A>ooo</div>" * 2000 + "</body></html>"
    io = IO::Memory.new(str)

    parser = Myhtml::Parser.new(io)
    c = 0
    parser.nodes(:div).each do |node|
      c += 1 if node.attribute_by("class") == "A"
    end
    c.should eq 2000
  end

  it "to_html" do
    origin = <<-HTML
      <!doctype html>
      <html lang=en>
        <head>
         <title></title>
        </head>
        <body> </body>
      </html>
    HTML
    parser = Myhtml::Parser.new(origin)
    parser.to_html.should eq "<!DOCTYPE html><html lang=\"en\"><head>\n     <title></title>\n    </head>\n    <body> \n  </body></html>"
  end
end
