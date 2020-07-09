require "./spec_helper"

require "../src/wordsmith/inflector/**"
require "../src/wordsmith/inflections"
require "./support/inflector_test_cases"

include InflectorTestCases

describe Wordsmith::Inflector do
  describe "pluralize" do
    SingularToPlural.each do |singular, plural|
      it "should pluralize #{singular}" do
        Wordsmith::Inflector.pluralize(singular).should eq plural
        Wordsmith::Inflector.pluralize(singular.capitalize).should eq plural.capitalize
      end
    end

    it "should pluralize empty string" do
      Wordsmith::Inflector.pluralize("").should eq ""
    end

    SingularToPlural.each do |singular, plural|
      it "should pluralize #{plural}" do
        Wordsmith::Inflector.pluralize(plural).should eq plural
        Wordsmith::Inflector.pluralize(plural.capitalize).should eq plural.capitalize
      end
    end
  end

  describe "singular" do
    SingularToPlural.each do |singular, plural|
      it "should singularize #{plural}" do
        Wordsmith::Inflector.singularize(plural).should eq singular
        Wordsmith::Inflector.singularize(plural.capitalize).should eq singular.capitalize
      end
    end

    SingularToPlural.each do |singular, plural|
      it "should singularize #{singular}" do
        Wordsmith::Inflector.singularize(singular).should eq singular
        Wordsmith::Inflector.singularize(singular.capitalize).should eq singular.capitalize
      end
    end
  end

  describe "camelize" do
    InflectorTestCases::CamelToUnderscore.each do |camel, underscore|
      it "should camelize #{underscore}" do
        Wordsmith::Inflector.camelize(underscore).should eq camel
      end
    end

    it "should not capitalize" do
      Wordsmith::Inflector.camelize("active_model", false).should eq "activeModel"
      Wordsmith::Inflector.camelize("active_model/errors", false).should eq "activeModel::Errors"
    end

    it "test camelize with lower downcases the first letter" do
      Wordsmith::Inflector.camelize("Capital", false).should eq "capital"
    end

    it "test camelize with underscores" do
      Wordsmith::Inflector.camelize("Camel_Case").should eq "CamelCase"
    end
  end

  describe "underscore" do
    CamelToUnderscore.each do |camel, underscore|
      it "should underscore #{camel}" do
        Wordsmith::Inflector.underscore(camel).should eq underscore
      end
    end

    CamelToUnderscoreWithoutReverse.each do |camel, underscore|
      it "should underscore without reverse #{camel}" do
        Wordsmith::Inflector.underscore(camel).should eq underscore
      end
    end

    CamelWithModuleToUnderscoreWithSlash.each do |camel, underscore|
      it "should camelize with module #{underscore}" do
        Wordsmith::Inflector.camelize(underscore).should eq camel
      end
    end

    CamelWithModuleToUnderscoreWithSlash.each do |camel, underscore|
      it "should underscore with slashes #{camel}" do
        Wordsmith::Inflector.underscore(camel).should eq underscore
      end
    end
  end

  describe "humanize" do
    UnderscoreToHuman.each do |underscore, human|
      it "should humanize #{underscore}" do
        Wordsmith::Inflector.humanize(underscore).should eq human
      end
    end

    UnderscoreToHumanWithoutCapitalize.each do |underscore, human|
      it "should not capitalize #{underscore}" do
        Wordsmith::Inflector.humanize(underscore, capitalize: false).should eq human
      end
    end

    UnderscoreToHumanWithKeepIdSuffix.each do |underscore, human|
      it "should keep id suffix #{underscore}" do
        Wordsmith::Inflector.humanize(underscore, keep_id_suffix: true).should eq human
      end
    end
  end

  describe "upcase_first" do
    it "should upcase first" do
      tests = {
        "what a Lovely Day" => "What a Lovely Day",
        "w"                 => "W",
        ""                  => "",
      }

      tests.each do |from, to|
        Wordsmith::Inflector.upcase_first(from).should eq to
      end
    end
  end

  describe "titleize" do
    MixtureToTitleCase.each do |before, titleized|
      it "should titleize mixture to title case #{before}" do
        Wordsmith::Inflector.titleize(before).should eq titleized
      end
    end

    MixtureToTitleCaseWithKeepIdSuffix.each do |before, titleized|
      it "should titleize with keep id suffix mixture to title case #{before}" do
        Wordsmith::Inflector.titleize(before, keep_id_suffix: true).should eq titleized
      end
    end
  end

  describe "tableize" do
    ClassNameToTableName.each do |class_name, table_name|
      it "should tableize #{class_name}" do
        Wordsmith::Inflector.tableize(class_name).should eq table_name
      end
    end
  end

  describe "classify" do
    ClassNameToTableName.each do |class_name, table_name|
      it "should classify #{table_name}" do
        Wordsmith::Inflector.classify(table_name).should eq class_name
        Wordsmith::Inflector.classify("table_prefix." + table_name).should eq class_name
      end
    end

    it "should classify with symbol" do
      Wordsmith::Inflector.classify(:foo_bars).should eq "FooBar"
    end

    it "should classify with leading schema name" do
      Wordsmith::Inflector.classify("schema.foo_bar").should eq "FooBar"
    end
  end

  describe "dasherize" do
    UnderscoresToDashes.each do |underscored, dasherized|
      it "should dasherize #{underscored}" do
        Wordsmith::Inflector.dasherize(underscored).should eq dasherized
      end
    end

    UnderscoresToDashes.each_key do |underscored|
      it "should underscore as reverse of dasherize #{underscored}" do
        Wordsmith::Inflector.underscore(Wordsmith::Inflector.dasherize(underscored)).should eq underscored
      end
    end
  end

  describe "demodulize" do
    demodulize_tests = {
      "MyApplication::Billing::Account" => "Account",
      "Account"                         => "Account",
      "::Account"                       => "Account",
      ""                                => "",
    }

    demodulize_tests.each do |from, to|
      it "should demodulize #{from}" do
        Wordsmith::Inflector.demodulize(from).should eq to
      end
    end
  end

  describe "deconstantize" do
    deconstantize_tests = {
      "MyApplication::Billing::Account"   => "MyApplication::Billing",
      "::MyApplication::Billing::Account" => "::MyApplication::Billing",
      "MyApplication::Billing"            => "MyApplication",
      "::MyApplication::Billing"          => "::MyApplication",
      "Account"                           => "",
      "::Account"                         => "",
      ""                                  => "",
    }

    deconstantize_tests.each do |from, to|
      it "should deconstantize #{from}" do
        Wordsmith::Inflector.deconstantize(from).should eq to
      end
    end
  end

  describe "foreign_key" do
    ClassNameToForeignKeyWithUnderscore.each do |klass, foreign_key|
      it "should foreign key #{klass}" do
        Wordsmith::Inflector.foreign_key(klass).should eq foreign_key
      end
    end

    ClassNameToForeignKeyWithoutUnderscore.each do |klass, foreign_key|
      it "should foreign key without underscore #{klass}" do
        Wordsmith::Inflector.foreign_key(klass, false).should eq foreign_key
      end
    end
  end

  describe "ordinal" do
    OrdinalNumbers.each do |number, ordinalized|
      it "should ordinal #{number}" do
        (number + Wordsmith::Inflector.ordinal(number)).should eq ordinalized
      end
    end
  end

  describe "ordinalize" do
    OrdinalNumbers.each do |number, ordinalized|
      it "should ordinalize #{number}" do
        Wordsmith::Inflector.ordinalize(number).should eq ordinalized
      end
    end
  end

  describe "irregularities" do
    Irregularities.each do |singular, plural|
      it "should handle irregularity between #{singular} and #{plural}" do
        Wordsmith::Inflector.inflections.irregular(singular, plural)
        Wordsmith::Inflector.singularize(plural).should eq singular
        Wordsmith::Inflector.pluralize(singular).should eq plural
      end
    end

    Irregularities.each do |singular, plural|
      it "should pluralize irregularity #{plural} should be the same" do
        Wordsmith::Inflector.inflections.irregular(singular, plural)
        Wordsmith::Inflector.pluralize(plural).should eq plural
      end
    end

    Irregularities.each do |singular, plural|
      it "should singularize irregularity #{singular} should be the same" do
        Wordsmith::Inflector.inflections.irregular(singular, plural)
        Wordsmith::Inflector.singularize(singular).should eq singular
      end
    end
  end

  describe "acronyms" do
    Wordsmith::Inflector.inflections.acronym("API")
    Wordsmith::Inflector.inflections.acronym("HTML")
    Wordsmith::Inflector.inflections.acronym("HTTP")
    Wordsmith::Inflector.inflections.acronym("RESTful")
    Wordsmith::Inflector.inflections.acronym("W3C")
    Wordsmith::Inflector.inflections.acronym("PhD")
    Wordsmith::Inflector.inflections.acronym("RoR")
    Wordsmith::Inflector.inflections.acronym("SSL")

    #  camelize             underscore            humanize              titleize
    [
      ["API", "api", "API", "API"],
      ["APIController", "api_controller", "API controller", "API Controller"],
      ["Nokogiri::HTML", "nokogiri/html", "Nokogiri/HTML", "Nokogiri/HTML"],
      ["HTTPAPI", "http_api", "HTTP API", "HTTP API"],
      ["HTTP::Get", "http/get", "HTTP/get", "HTTP/Get"],
      ["SSLError", "ssl_error", "SSL error", "SSL Error"],
      ["RESTful", "restful", "RESTful", "RESTful"],
      ["RESTfulController", "restful_controller", "RESTful controller", "RESTful Controller"],
      ["Nested::RESTful", "nested/restful", "Nested/RESTful", "Nested/RESTful"],
      ["IHeartW3C", "i_heart_w3c", "I heart W3C", "I Heart W3C"],
      ["PhDRequired", "phd_required", "PhD required", "PhD Required"],
      ["IRoRU", "i_ror_u", "I RoR u", "I RoR U"],
      ["RESTfulHTTPAPI", "restful_http_api", "RESTful HTTP API", "RESTful HTTP API"],
      ["HTTP::RESTful", "http/restful", "HTTP/RESTful", "HTTP/RESTful"],
      ["HTTP::RESTfulAPI", "http/restful_api", "HTTP/RESTful API", "HTTP/RESTful API"],
      ["APIRESTful", "api_restful", "API RESTful", "API RESTful"],

      # misdirection
      ["Capistrano", "capistrano", "Capistrano", "Capistrano"],
      ["CapiController", "capi_controller", "Capi controller", "Capi Controller"],
      ["HttpsApis", "https_apis", "Https apis", "Https Apis"],
      ["Html5", "html5", "Html5", "Html5"],
      ["Restfully", "restfully", "Restfully", "Restfully"],
      ["RoRails", "ro_rails", "Ro rails", "Ro Rails"],
    ].each do |words|
      camel, under, human, title = words
      it "should handle acronym #{camel}" do
        Wordsmith::Inflector.camelize(under).should eq camel
        Wordsmith::Inflector.camelize(camel).should eq camel
        Wordsmith::Inflector.underscore(under).should eq under
        Wordsmith::Inflector.underscore(camel).should eq under
        Wordsmith::Inflector.titleize(under).should eq title
        Wordsmith::Inflector.titleize(camel).should eq title
        Wordsmith::Inflector.humanize(under).should eq human
      end
    end

    it "should handle acronym override" do
      Wordsmith::Inflector.inflections.acronym("API")
      Wordsmith::Inflector.inflections.acronym("LegacyApi")

      Wordsmith::Inflector.camelize("legacyapi").should eq "LegacyApi"
      Wordsmith::Inflector.camelize("legacy_api").should eq "LegacyAPI"
      Wordsmith::Inflector.camelize("some_legacyapi").should eq "SomeLegacyApi"
      Wordsmith::Inflector.camelize("nonlegacyapi").should eq "Nonlegacyapi"
    end

    it "should handle acronyms camelize lower" do
      Wordsmith::Inflector.inflections.acronym("API")
      Wordsmith::Inflector.inflections.acronym("HTML")

      Wordsmith::Inflector.camelize("html_api", false).should eq "htmlAPI"
      Wordsmith::Inflector.camelize("htmlAPI", false).should eq "htmlAPI"
      Wordsmith::Inflector.camelize("HTMLAPI", false).should eq "htmlAPI"
    end

    it "should handle underscore acronym sequence" do
      Wordsmith::Inflector.inflections.acronym("API")
      Wordsmith::Inflector.inflections.acronym("JSON")
      Wordsmith::Inflector.inflections.acronym("HTML")

      Wordsmith::Inflector.underscore("JSONHTMLAPI").should eq "json_html_api"
    end
  end

  describe "clear" do
    it "should clear all" do
      # ensure any data is present
      Wordsmith::Inflector.inflections.plural(/(quiz)$/i, "\\1zes")
      Wordsmith::Inflector.inflections.singular(/(database)s$/i, "\\1")
      Wordsmith::Inflector.inflections.uncountable("series")
      Wordsmith::Inflector.inflections.human("col_rpted_bugs", "Reported bugs")

      Wordsmith::Inflector.inflections.clear :all

      Wordsmith::Inflector.inflections.plurals.empty?.should be_true
      Wordsmith::Inflector.inflections.singulars.empty?.should be_true
      Wordsmith::Inflector.inflections.uncountables.empty?.should be_true
      Wordsmith::Inflector.inflections.humans.empty?.should be_true
    end

    it "should clear with default" do
      # ensure any data is present
      Wordsmith::Inflector.inflections.plural(/(quiz)$/i, "\\1zes")
      Wordsmith::Inflector.inflections.singular(/(database)s$/i, "\\1")
      Wordsmith::Inflector.inflections.uncountable("series")
      Wordsmith::Inflector.inflections.human("col_rpted_bugs", "Reported bugs")

      Wordsmith::Inflector.inflections.clear

      Wordsmith::Inflector.inflections.plurals.empty?.should be_true
      Wordsmith::Inflector.inflections.singulars.empty?.should be_true
      Wordsmith::Inflector.inflections.uncountables.empty?.should be_true
      Wordsmith::Inflector.inflections.humans.empty?.should be_true
    end
  end

  describe "humans" do
    it "should humanize by rule" do
      Wordsmith::Inflector.inflections.human(/_cnt$/i, "\\1_count")
      Wordsmith::Inflector.inflections.human(/^prefx_/i, "\\1")

      Wordsmith::Inflector.humanize("jargon_cnt").should eq "Jargon count"
      Wordsmith::Inflector.humanize("prefx_request").should eq "Request"
    end

    it "should humanize by string" do
      Wordsmith::Inflector.inflections.human("col_rpted_bugs", "Reported bugs")

      Wordsmith::Inflector.humanize("col_rpted_bugs").should eq "Reported bugs"
      Wordsmith::Inflector.humanize("COL_rpted_bugs").should eq "Col rpted bugs"
    end

    it "should humanize with acronyms" do
      Wordsmith::Inflector.inflections.acronym("LAX")
      Wordsmith::Inflector.inflections.acronym("SFO")

      Wordsmith::Inflector.humanize("LAX ROUNDTRIP TO SFO").should eq "LAX roundtrip to SFO"
      Wordsmith::Inflector.humanize("LAX ROUNDTRIP TO SFO", capitalize: false).should eq "LAX roundtrip to SFO"
      Wordsmith::Inflector.humanize("lax roundtrip to sfo").should eq "LAX roundtrip to SFO"
      Wordsmith::Inflector.humanize("lax roundtrip to sfo", capitalize: false).should eq "LAX roundtrip to SFO"
      Wordsmith::Inflector.humanize("Lax Roundtrip To Sfo").should eq "LAX roundtrip to SFO"
      Wordsmith::Inflector.humanize("Lax Roundtrip To Sfo", capitalize: false).should eq "LAX roundtrip to SFO"
    end
  end
end
