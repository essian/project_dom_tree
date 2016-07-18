require 'dom_parser'

describe DomParser do
  let(:opening) {Node.new("<p>", nil, nil)}
  let(:opening_dup) {Node.new("<p>", nil, nil)}
  let(:closing) {Node.new("</p>", nil, nil)}
  let(:text) {Node.new(" hello world ", nil, nil)}

  describe "#html_to_array" do
    it "converts a string to array of tags" do
      string = "<div>  div text before  <p>    p text  </p>  <div>    more div text  </div>  div text after</div>"
      expect(subject.html_to_array(string).length).to eq(11)
    end

    it "parses a tag correctly" do
      string ="<div class='foo bar'>"
      expect(subject.html_to_array(string).first).to eq(["<div class='foo bar'>"])
    end

    it "parses a text element" do
      string ="<div class='foo bar'> hello </div>"
      expect(subject.html_to_array(string)[1]).to eq([" hello "])
    end

    it "parses two tags" do
      string = "<p></p>"
      expect(subject.html_to_array(string)).to eq([["<p>"], ["</p>"]])
    end

    it "parses 4 children" do
      string = "<h1><p>hello</p><p>bye</p></h1>"
      expect(subject.html_to_array(string)).to eq([["<h1>"], ["<p>"], ["hello"], ["</p>"], ["<p>"], ["bye"], ["</p>"], ["</h1>"]])
    end

  end

  describe "#parse_tag" do
    it "returns a hash tag type and attributes" do
      tag = "<p class=\"foo bar\" id='baz' src = 'hello' >"
      expect(subject.parse_tag(tag).keys).to eq([:type, :class, :id, :src])
    end

    it "has the correct values for each key" do
      tag = "<p class=\"foo bar\" id='baz' src = 'hello' >"
      expect(subject.parse_tag(tag).values).to eq(["p", "foo bar", "baz", "hello"])
    end

    it "handles closing tags" do
      tag = "</p>"
      expect(subject.parse_tag(tag)[:type]).to eq("p")
    end

  end

  describe "#tag?" do
    let(:node) { Node.new("<p>", nil, nil)}
    it "returns true if node data is an html tag" do
      expect(subject.tag?(node)).to be true
    end

    it "returns false if node data is text" do
      node = Node.new("hello", nil, nil)
      expect(subject.tag?(node)).to be false
    end
  end

  describe "#closing?" do
    it "returns true if passed a closing tag" do
      expect(subject.closing?(closing)).to be true
    end

    it "returns false if passed an opening tag" do
      expect(subject.closing?(opening)).to be false
    end

    it "returns false if text is passed in" do
      expect(subject.closing?(text)). to be false
    end
  end

  describe "#text?" do
    it "returns true if node is not a tag" do
      expect(subject.text?(text)).to be true
    end
  end

  describe "#create_tree" do
    let(:one_tag) { "<p></p>"}
    let(:two_tag) { "<p><a></a></p>"}
    let(:one_tag_text) { "<h1>hello world</h1>"}
    let(:two_childs) { "<h1><p></p><p></p></h1>"}
    let(:two_childs_with_text) { "<h1><p>hello</p><p>bye</p></h1>"}


    it "sets the root node to the first tag in the string" do
      subject.create_tree(one_tag)
      expect(subject.root.data).to eq("<p>")
      expect(subject.root.children).to eq([])
    end

    it "creates a child node for the second tag in the string" do
      subject.create_tree(two_tag)
      expect(subject.root.children[0].data).to eq("<a>")
      expect(subject.root.children[0].parent.data).to eq("<p>")
    end

    it "creates a child node for a text element" do
      subject.create_tree(one_tag_text)
      expect(subject.root.children[0].data).to eq("hello world")
      expect(subject.root.children[0].parent.data).to eq("<h1>")
      expect(subject.root.children.count).to eq(1)
    end

    it "creates a child node for each child element" do
      subject.create_tree(two_childs)
      expect(subject.root.children.count).to eq(2)

    end

    it "creates a child node for each child element" do
      subject.create_tree(two_childs_with_text)
      puts "kids are"
      p subject.root.children
      expect(subject.root.children.count).to eq(2)

    end

  end

  describe "#create_node" do
    it "receives a tag and creates a node" do
      node = subject.create_node(["<p>"])
      expect(node.data).to eq("<p>")
      expect(node.parent).to eq(nil)
      expect(node.children).to eq([])
    end
  end
end


# describe "#closing_tag?" do
#   it "validates a normal closing tag" do
#     tag = "</a>"
#     expect(subject.closing_tag?(tag)).to be(true)
#   end

#   it "returns false when passed an opening tag" do
#     tag = "<a>"
#     expect(subject.closing_tag?(tag)).to be(false)
#   end
# end

# describe "#opening_tag?" do
#   it "returns true when passed an opening tag" do
#     tag = "<a>"
#     expect(subject.opening_tag?(tag)).to be(true)
#   end

#   it "returns false when passed an closing tag" do
#     tag = "</a>"
#     expect(subject.opening_tag?(tag)).to be(false)
#   end
# end
