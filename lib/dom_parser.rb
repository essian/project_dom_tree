Node = Struct.new(:data, :children, :parent)

class DomParser
  attr_accessor :root
  def initialize
    #@html = html
    @root = nil
  end

  def parser_script(string)
    create_tree(string)
    retrieve
  end

  def html_to_array(string)
    # string.scan(/((?<=>).+?(?=<)|<.*?>)/)
    string.scan(/(<.*?>|(?<=>).+?(?=<))/)
  end

  def parse_tag(string)
    tag = {}

    # save tag after < character
    tag_type = string.match(/<\/?(\w+)(?:>| )/)

    # saves either side of an equal sign
    attributes = string.scan(/(\w+)\s*=\s*['"](.*?)['"]/)

    #options
    options = string.scan(/\s*(\w)\s*[?!==]/)

    tag[:type] = tag_type[1]
    attributes.each do |attribute|
      tag[attribute[0].to_sym] = attribute[1]
    end

    tag
  end

  def create_tree(string)
    tags = html_to_array(string)
    @root = create_node(tags[0])
    current_node = @root
    tags[1..-1].each do |tag|
      node = create_node(tag)
      if closing?(node)
        break unless current_node.parent
        current_node = current_node.parent

      elsif tag?(node)
        current_node.children << node
        node.parent = current_node
        current_node = node

      elsif text?(node)
        current_node.children << node
        node.parent = current_node

      end
    end
  end

  def retrieve
    stack = []
    stack << @root
    until stack.empty?
      current_node = stack.pop
      puts current_node.data
      unless current_node.children.empty?
        current_node.children.each { |child| stack.push(child)} unless current_node.children.empty?
      end
    end
  end

  def create_node(tag, parent = nil)
    Node.new(tag[0], [], parent)
  end

  def tag?(node)
    node.data[0] == '<'
  end

  def text?(node)
    !node.data.include?('<')
  end

  def closing?(node)
    node.data[0..1] == "</"
  end




  # def opening_tag?(tag)
  #   !closing_tag?(tag) && tag[0]=="<"
  # end

  # def closing_tag?(element)
  #   element[1] == "/"
  # end
end

d = DomParser.new
html_string = "<div>  div text before  <p>    p text  </p>  <div>    more div text  </div>  div text after</div>"
d.parser_script(html_string)
