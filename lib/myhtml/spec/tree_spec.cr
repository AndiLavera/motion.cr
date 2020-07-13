require "./spec_helper"

describe Myhtml::Tree do
  describe "#create_node" do
    it "returns a new Myhtml::Node" do
      tree = Myhtml::Tree.new

      node = tree.create_node(:a)

      node.should be_a(Myhtml::Node)
      node.tag_id.should eq(Myhtml::Lib::MyhtmlTags::MyHTML_TAG_A)
    end

    it "create node with attributes and text" do
      tree = Myhtml::Tree.new
      node = tree.create_node(:a)
      node.attribute_add("id", "bla")
      node.attribute_add("class", "red")
      node.to_html.should eq "<a id=\"bla\" class=\"red\"></a>"

      node.inner_text = "some text"

      node.to_html.should eq "<a id=\"bla\" class=\"red\">some text</a>"
    end
  end
end
