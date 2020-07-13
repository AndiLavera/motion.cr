require "../src/myhtml"

# This page encoded in windows-1251
page = File.read("./spec/fixtures/25.htm")

# by default page parsed as UTF-8
myhtml = Myhtml::Parser.new(page)
p myhtml.encoding                     # => MyENCODING_DEFAULT
p myhtml.nodes(:div).first.inner_text # => "\xC7\xE0\xE3\xF0\xF3\xE7\xEA\xE0...

# set encoding directly
myhtml = Myhtml::Parser.new(page, encoding: Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251)
p myhtml.encoding                     # => MyENCODING_WINDOWS_1251
p myhtml.nodes(:div).first.inner_text # => "Загрузка. Пожалуйста, подождите..."

# set encoding from header
encoding = Myhtml::Utils::DetectEncoding.from_header?("text/html; charset=Windows-1251")
myhtml = Myhtml::Parser.new(page, encoding: encoding)
p myhtml.encoding                     # => MyENCODING_WINDOWS_1251
p myhtml.nodes(:div).first.inner_text # => "Загрузка. Пожалуйста, подождите..."

# try to find encoding from <meta charset=...>
myhtml = Myhtml::Parser.new(page, detect_encoding_from_meta: true)
p myhtml.encoding                     # => MyENCODING_WINDOWS_1251
p myhtml.nodes(:div).first.inner_text # => "Загрузка. Пожалуйста, подождите..."

# try to detect encoding by trigrams (slow, and not 100% correct)
myhtml = Myhtml::Parser.new(page, detect_encoding: true)
p myhtml.encoding                     # => MyENCODING_WINDOWS_1251
p myhtml.nodes(:div).first.inner_text # => "Загрузка. Пожалуйста, подождите..."
