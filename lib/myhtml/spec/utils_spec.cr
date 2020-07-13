require "./spec_helper"

describe Myhtml::Utils do
  context "from_header" do
    it { Myhtml::Utils::DetectEncoding.from_header("text/html; charset=utf-8").should eq Myhtml::Lib::MyEncodingList::MyENCODING_DEFAULT }
    it { Myhtml::Utils::DetectEncoding.from_header("text/html; charset=O_o").should eq Myhtml::Utils::DetectEncoding::EncodingNotFound.new("O_o") }
    it { Myhtml::Utils::DetectEncoding.from_header("text/html; charset=unicode").should eq Myhtml::Utils::DetectEncoding::EncodingNotFound.new("unicode") }
    it { Myhtml::Utils::DetectEncoding.from_header("text/html; charset=Windows-1251").should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml::Utils::DetectEncoding.from_header("text/html; charset=cp1251").should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml::Utils::DetectEncoding.from_header("text/html; charset=cp-1251").should eq Myhtml::Utils::DetectEncoding::EncodingNotFound.new("cp-1251") }
    it { Myhtml::Utils::DetectEncoding.from_header("text/html; charset='cp1251'").should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml::Utils::DetectEncoding.from_header("text/html; charset=\"cp1251\"").should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml::Utils::DetectEncoding.from_header("text/html; charset=euc-jp").should eq Myhtml::Lib::MyEncodingList::MyENCODING_EUC_JP }
    it { Myhtml::Utils::DetectEncoding.from_header("text/html; charset=").should eq Myhtml::Utils::DetectEncoding::EncodingNotFound.new("") }
    it { Myhtml::Utils::DetectEncoding.from_header("text/html").should eq Myhtml::Utils::DetectEncoding::EncodingNotFound.new("") }
    it { Myhtml::Utils::DetectEncoding.from_header?("text/html").should eq nil }
    it { Myhtml::Utils::DetectEncoding.from_header("asdfadsfaf r231 r8&(^(*^$&^%#s&^$&^%$^%$@$%%{!#$#$&^^*}&^").should eq Myhtml::Utils::DetectEncoding::EncodingNotFound.new("") }
  end

  context "from_meta" do
    it { Myhtml::Utils::DetectEncoding.from_meta(%q{<meta http-equiv="Content-Type" content="text/html; charset=windows-1251" />}).should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml::Utils::DetectEncoding.from_meta(%q{<meta http-equiv="Content-Type" content="text/html; charset=windows-1251" />}).should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml::Utils::DetectEncoding.from_meta?(%q{<meta http-equiv="Content-Type" content="text/html; charset=" />}).should eq nil }
    it { Myhtml::Utils::DetectEncoding.from_meta(%q{<meta http-equiv="Content-Type" content="text/html; charset=" />}).should eq Myhtml::Utils::DetectEncoding::EncodingNotFound.new("") }
    it { Myhtml::Utils::DetectEncoding.from_meta?(%q{<meta http-equiv="Content-Type" content="text/html; charset=rtf" />}).should eq nil }
    it { Myhtml::Utils::DetectEncoding.from_meta(%q{<meta http-equiv="Content-Type" content="text/html; charset=rtf" />}).should eq Myhtml::Utils::DetectEncoding::EncodingNotFound.new("rtf") }
  end

  context "detect?" do
    it { Myhtml::Utils::DetectEncoding.detect?(PAGE25).should eq Myhtml::Lib::MyEncodingList::MyENCODING_WINDOWS_1251 }
    it { Myhtml::Utils::DetectEncoding.detect?("abc" * 1000).should eq Myhtml::Lib::MyEncodingList::MyENCODING_DEFAULT }
    it { Myhtml::Utils::DetectEncoding.detect?("").should eq Myhtml::Lib::MyEncodingList::MyENCODING_DEFAULT }
  end
end
