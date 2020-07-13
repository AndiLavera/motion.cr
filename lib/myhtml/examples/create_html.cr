# Example: create html

require "../src/myhtml"

tree = Myhtml::Tree.new

html = tree.create_node(:html)
tree.document!.append_child(html)

head = tree.create_node(:head)
html.append_child(head)

body = tree.create_node(:body)
html.append_child(body)

div = tree.create_node(:div)
div["class"] = "red"
body.append_child(div)

a = tree.create_node(:a)
a.inner_text = "O_o"
a["href"] = "/#"

div.append_child(a)

puts tree.to_pretty_html

# Output:
# <html>
#   <head></head>
#   <body>
#     <div class="red">
#       <a href="/#">
#         O_o
#       </a>
#     </div>
#   </body>
# </html>
