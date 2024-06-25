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
        if /if else let /let with /let for /for unset properties
      )

      keywords_type = %w(
        bool byte char double float int long
        sbyte short string uint ulong ushort uitext
      )

      # Documentation: https://www.w3.org/TR/xml11/#charsets and https://www.w3.org/TR/xml11/#sec-suggested-names

      def self.detect?(text)
        return true if text =~ /\A<\?fluxx\b/
      end

      identifier = /@?[_a-z]\w*/i
      openTag = %r(<[\p{L}:_][\p{Word}\p{Cf}:.·-]*|<\n)
      closeTag = %r(\/[\p{L}:_][\p{Word}\p{Cf}:.·-]*>|/>)
      
      state :root do
        mixin :whitespace

        rule %r/(#{keywords.join('|')})/, Keyword
        rule %r/\b(#{keywords_type.join('|')})\b/, Keyword::Type

        rule identifier, Name

        rule %r/=>/, Punctuation
        rule %r/=/, Punctuation
        rule %r/;/, Punctuation
        rule %r/,/, Punctuation
        rule %r/\./, Punctuation

        rule %r(
          [0-9](?:[_0-9]*[0-9])?
          ([.][0-9](?:[_0-9]*[0-9])?)? # decimal
          (e[+-]?[0-9](?:[_0-9]*[0-9])?)? # exponent
          [fldum]? # type
        )ix, Num

        rule %r/#[0-9a-f]{1,6}/i, Num # colors

        rule %r/[\p{L}:_][\p{Word}\p{Cf}:.·-]*=/, Name::Attribute, :propertyValue    # property=

        rule openTag, Name::Tag
        rule closeTag, Name::Tag
      end

      state :whitespace do
        rule %r/\s+/m, Text
        rule %r(//.*?$), Comment::Single

        rule %r/<!--/, Comment::Multiline, :xmlStyleComment
      end

      state :xmlStyleComment do
        rule %r/[^-]+/m, Comment::Multiline
        rule %r/-->/, Comment::Multiline, :pop!
        rule %r/-/, Comment::Multiline
      end

      state :propertyValue do
        rule %r/[^;^\n^\/^<]+/, Str
        rule %r/;/, Punctuation, :pop!
        rule %r/\n/, Text, :pop!

        rule openTag, Name::Tag

        rule closeTag, Name::Tag, :pop!
      end
    end
  end
end
