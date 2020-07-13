# Example: basic usage

require "../src/myhtml"

html = <<-HTML
  <html>
    <body>
      <div id="t1" class="red">
        <a href="/#">O_o</a>
      </div>
      <div id="t2"></div>
    </body>
  </html>
HTML

myhtml = Myhtml::Parser.new(html)

myhtml.nodes(:div).each do |node|
  id = node.attribute_by("id")

  if first_link = node.scope.nodes(:a).first?
    href = first_link.attribute_by("href")
    link_text = first_link.inner_text

    puts "div with id #{id} have link [#{link_text}](#{href})"
  else
    puts "div with id #{id} have no links"
  end
end

# Output:
#   div with id t1 have link [O_o](/#)
#   div with id t2 have no links
