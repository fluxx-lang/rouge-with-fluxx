# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class Fluxx < RegexLexer
      title "Fluxx"
      desc %q(<desc for="this-lexer">Fluxx</desc>)
      tag 'fluxx'
      filenames '*.fluxx', '*.fx'

      keywords = %w(
        if let with for properties
      )

      keywords_type = %w(
        bool byte char double float int long
        sbyte short string uint ulong ushort uitext
      )

      # Documentation: https://www.w3.org/TR/xml11/#charsets and https://www.w3.org/TR/xml11/#sec-suggested-names

      def self.detect?(text)
        return true if text =~ /\A<\?fluxx\b/
      end
      
      state :root do
        rule %r/[^<&]+/, Text
        rule %r/&\S*?;/, Name::Entity
        rule %r/<!--/, Comment, :comment

        # open tags
        rule %r(<[\p{L}:_][\p{Word}\p{Cf}:.·-]*), Name::Tag, :tag

        rule %r/\b(#{keywords.join('|')})\b/, Keyword
        rule %r/\b(#{keywords_type.join('|')})\b/, Keyword::Type
      end

      state :comment do
        rule %r/[^-]+/m, Comment
        rule %r/-->/, Comment, :pop!
        rule %r/-/, Comment
      end

      state :tag do
        rule %r/\s+/m, Text
        rule %r/[\p{L}:_][\p{Word}\p{Cf}:.·-]*\s*=/m, Name::Attribute, :propertyValue

        # close tags
        rule(/\/[\p{L}:_][\p{Word}\p{Cf}:.·-]*>/) { token Name::Tag; pop! 1 }
        rule(/\/>/) { token Name::Tag; pop! 1 }
      end

      state :propertyValue do
        rule %r/[^;^\n^\/^<]+/, Text
        rule %r/;/, Punctuation, :pop!
        rule %r/\n/, Text::Whitespace, :pop!

        # open tags
        rule %r(<[\p{L}:_][\p{Word}\p{Cf}:.·-]*), Name::Tag, :tag

        # close tags
        rule(/\/[\p{L}:_][\p{Word}\p{Cf}:.·-]*>/) { token Name::Tag; pop! 2 }
        rule(/\/>/) { token Name::Tag; pop! 2 }
      end
    end
  end
end
