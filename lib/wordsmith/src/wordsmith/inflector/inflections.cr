module Wordsmith
  module Inflector
    extend self

    class Inflections
      class Uncountables < Array(String)
        def initialize
          @regex_array = Array(Regex).new
          super
        end

        def delete(entry)
          super entry
          @regex_array.delete(to_regex(entry))
        end

        def <<(*word)
          add(word)
        end

        def add(words)
          words = words.to_a.flatten.map { |word| word.downcase }
          concat(words)
          @regex_array += words.map { |word| to_regex(word) }
          self
        end

        def uncountable?(str)
          @regex_array.any? { |regex| regex.match(str) }
        end

        private def to_regex(string)
          /\b#{::Regex.escape(string)}\Z/i
        end
      end

      getter :plurals, :singulars, :uncountables, :humans, :acronyms, :acronym_regex

      def initialize
        @plurals = Hash(Regex, String).new
        @singulars = Hash(Regex, String).new
        @uncountables = Uncountables.new
        @humans = Hash(Regex, String).new
        @acronyms = Hash(String, String).new
        @acronym_regex = /(?=a)b/
      end

      def acronym(word)
        @acronyms[word.downcase] = word
        @acronym_regex = /#{acronyms.values.join("|")}/
      end

      def plural(rule : String | Regex, replacement : String)
        if rule.is_a?(String)
          @uncountables.delete(rule)
          rule = /#{rule}/
        end
        @uncountables.delete(replacement)
        new_plural = {rule => replacement}
        @plurals = new_plural.merge(@plurals)
      end

      def singular(rule : String | Regex, replacement : String)
        if rule.is_a?(String)
          @uncountables.delete(rule)
          rule = /#{rule}/
        end
        @uncountables.delete(replacement)
        new_singular = {rule => replacement}
        @singulars = new_singular.merge(@singulars)
      end

      def irregular(singular : String, plural : String)
        @uncountables.delete(singular)
        @uncountables.delete(plural)

        s0 = singular[0]
        srest = singular[1..-1]

        p0 = plural[0]
        prest = plural[1..-1]

        if s0.upcase == p0.upcase
          plural(/(#{s0})#{srest}$/i, "\\1" + prest)
          plural(/(#{p0})#{prest}$/i, "\\1" + prest)

          singular(/(#{s0})#{srest}$/i, "\\1" + srest)
          singular(/(#{p0})#{prest}$/i, "\\1" + srest)
        else
          plural(/#{s0.upcase}(?i)#{srest}$/, p0.upcase + prest)
          plural(/#{s0.downcase}(?i)#{srest}$/, p0.downcase + prest)
          plural(/#{p0.upcase}(?i)#{prest}$/, p0.upcase + prest)
          plural(/#{p0.downcase}(?i)#{prest}$/, p0.downcase + prest)

          singular(/#{s0.upcase}(?i)#{srest}$/, s0.upcase + srest)
          singular(/#{s0.downcase}(?i)#{srest}$/, s0.downcase + srest)
          singular(/#{p0.upcase}(?i)#{prest}$/, s0.upcase + srest)
          singular(/#{p0.downcase}(?i)#{prest}$/, s0.downcase + srest)
        end
      end

      def uncountable(*words)
        @uncountables.add(words.to_a)
      end

      def human(rule : String | Regex, replacement : String)
        rule = /#{rule}/ if rule.is_a?(String)
        @humans = {rule => replacement}.merge(@humans)
      end

      def clear(scope = :all)
        scopes = scope == :all ? [:plurals, :singulars, :uncountables, :humans] : [scope]

        scopes.each do |scope|
          case scope
          when :plurals
            @plurals = Hash(Regex, String).new
          when :singulars
            @singulars = Hash(Regex, String).new
          when :uncountables
            @uncountables = Uncountables.new
          when :humans
            @humans = Hash(Regex, String).new
          end
        end
      end
    end

    @@inflections = Inflections.new

    def inflections
      @@inflections
    end
  end
end
