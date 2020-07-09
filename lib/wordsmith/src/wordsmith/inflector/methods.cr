require "./inflections"

module Wordsmith
  module Inflector
    extend self

    def pluralize(word)
      apply_inflections(word, inflections.plurals)
    end

    def singularize(word)
      apply_inflections(word, inflections.singulars)
    end

    def camelize(term, uppercase_first_letter = true)
      string = term.to_s
      string = if uppercase_first_letter
                 string.sub(/^[a-z\d]*/) do |match|
                   inflections.acronyms[match]? || match.capitalize
                 end
               else
                 string.sub(/^(?:#{inflections.acronym_regex}(?=\b|[A-Z_])|\w)/) do |match|
                   match.downcase
                 end
               end
      string = string.gsub(/(?:_|(\/))([a-z\d]*)/i) do |_string, match|
        "#{match[1]?}#{inflections.acronyms[match[2]]? || match[2].capitalize}"
      end
      string = string.gsub("/", "::")
      string
    end

    def underscore(camel_cased_word)
      return camel_cased_word unless camel_cased_word =~ /[A-Z-]|::/
      word = camel_cased_word.to_s.gsub("::", "/")
      word = word.gsub(/(?:(?<=([A-Za-z\d]))|\b)(#{inflections.acronym_regex})(?=\b|[^a-z])/) do |_string, match|
        "#{match[1]? && "_"}#{match[2].downcase}"
      end
      word = word.gsub(/([A-Z\d]+)([A-Z][a-z])/, "\\1_\\2")
      word = word.gsub(/([a-z\d])([A-Z])/, "\\1_\\2")
      word = word.tr("-", "_")
      word = word.downcase
      word
    end

    def humanize(lower_case_and_underscored_word, capitalize = true, keep_id_suffix = false)
      result = lower_case_and_underscored_word.to_s.dup

      inflections.humans.each { |rule, replacement|
        if result.index(rule)
          result = result.sub(rule, replacement)
          break
        end
      }

      result = result.sub(/\A_+/, "")
      unless keep_id_suffix
        result = result.sub(/_id\z/, "")
      end
      result = result.tr("_", " ")

      result = result.gsub(/([a-z\d]*)/i) do |match|
        "#{inflections.acronyms[match.downcase]? || match.downcase}"
      end

      if capitalize
        result = result.sub(/\A\w/) { |match| match.upcase }
      end

      result
    end

    def upcase_first(string)
      string.size > 0 ? string[0].to_s.upcase + string[1..-1] : ""
    end

    def titleize(word, keep_id_suffix = false)
      humanize(underscore(word), keep_id_suffix: keep_id_suffix).gsub(/\b(?<!\w['’`])[a-z]/) do |match|
        match.capitalize
      end
    end

    def tableize(class_name)
      pluralize(underscore(class_name))
    end

    def classify(table_name)
      # strip out any leading schema name
      camelize(singularize(table_name.to_s.sub(/.*\./, "")))
    end

    def dasherize(underscored_word)
      underscored_word.tr("_", "-")
    end

    def demodulize(path)
      path = path.to_s
      if i = path.rindex("::")
        path[(i + 2)..-1]
      else
        path
      end
    end

    def deconstantize(path)
      path.to_s[0, path.rindex("::") || 0] # implementation based on the one in facets' Module#spacename
    end

    def foreign_key(class_name, separate_class_name_and_id_with_underscore = true)
      underscore(demodulize(class_name)) + (separate_class_name_and_id_with_underscore ? "_id" : "id")
    end

    def ordinal(number)
      abs_number = number.to_i.abs

      if (11..13).includes?(abs_number % 100)
        "th"
      else
        case abs_number % 10
        when 1; "st"
        when 2; "nd"
        when 3; "rd"
        else    "th"
        end
      end
    end

    def ordinalize(number)
      "#{number}#{ordinal(number)}"
    end

    private def apply_inflections(word, rules)
      result = word.to_s.dup

      if result.empty? || inflections.uncountables.uncountable?(result)
        result
      else
        rules.each { |rule, replacement|
          if result.index(rule)
            result = result.sub(rule, replacement)
            break
          end
        }
        result
      end
    end
  end
end
