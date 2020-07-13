require "./spec_helper"

describe Myhtml do
  it "parser work" do
    parser = Myhtml::Parser.new("<html>BLA</html>")

    parser.root!.tag_name.should eq "html"
    parser.root!.child!.tag_name.should eq "head"
    parser.root!.child!.next!.tag_name.should eq "body"
    parser.root!.child!.next!.child!.tag_text.should eq "BLA"
  end

  it "version" do
    v = Myhtml.version
    v.size.should be > 0
  end

  it "decode_html_entities" do
    Myhtml.decode_html_entities("").should eq ""
    Myhtml.decode_html_entities(" ").should eq " "
    Myhtml.decode_html_entities("Chris").should eq "Chris"
    Myhtml.decode_html_entities("asdf &#61 &amp - &amp; bla -- &Auml; asdf").should eq "asdf = & - & bla -- Ä asdf"
  end
end
