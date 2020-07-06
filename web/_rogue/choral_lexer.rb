# -*- coding: utf-8 -*- #
# frozen_string_literal: true

module Rouge
  module Lexers
    class Choral < RegexLexer
      title "Choral"
      desc "The Choral programming language"
      
      tag 'choral'
      filenames '*.ch'
      mimetypes 'text/x-choral'
      
      keywords = %w(
       case catch else if instanceof new return switch this throw try
      )
      
      declarations = %w(
        abstract enum extends final implements private protected
        public static super throws
      )    

      # types = %w(boolean byte char double float int long short var void)
      
      id = /[[:alpha:]_][[:word:]]*/
      const_name = /[[:upper:]][[:upper:][:digit:]_]*\b/
      class_name = /[[:upper:]][[:alnum:]]*\b/
      atWorld = /@/
            
      state :root do
        rule %r/[^\S\n]+/, Text
        rule %r(//.*?$), Comment::Single
        rule %r(/\*.*?\*/)m, Comment::Multiline
        # keywords: go before method names to avoid lexing "throw new XYZ"
        # as a method signature
        rule %r/(?:#{keywords.join('|')})\b/, Keyword
        
        # rule %r/(@)\s*(\()/ do | m |
        #   token Name::Namespace, m[1]
        #   token Text, m[2]
        #   goto :worlds
        # end
        
        rule %r(
        (\s*(?:[a-zA-Z_][a-zA-Z0-9_.\[\]<>]*\s+)+?) # return arguments
        ([a-zA-Z_][a-zA-Z0-9_]*)                  # method name
        (\s*)(\()                                 # signature start
        )mx do |m|
          # TODO: do this better, this shouldn't need a delegation
          delegate Choral, m[1]
          token Name::Function, m[2]
          token Text, m[3]
          token Operator, m[4]
        end
        
        # rule %r/@#{id}/, Name::Namespace
        rule %r/@#{id}/, Name::Decorator
        rule %r/(#{id})(#{atWorld})/ do | m |
          token Name, m[1]
          token Name::Namespace, m[2]
          goto :worldDeclWithoutAt
        end
        rule %r/(?:#{declarations.join('|')})\b/, Keyword::Declaration
        rule %r/(?:null)\b/, Keyword::Constant
        rule %r/(?:class|interface)\b/, Keyword::Declaration, :class
        rule %r/(?:import|package)\b/, Keyword::Namespace, :import
        rule %r/"(\\\\|\\"|[^"])*"/, Str, :worldDeclOrProd
        rule %r/'(?:\\.|[^\\]|\\u[0-9a-f]{4})'/, Str::Char, :worldDecl
        # rule %r/([\.:])(#{id})/ do
        #   groups Operator, Name::Attribute
        # end
        rule %r/(\.|::)/, Operator, :access
        # rule %r/(\.|::)(#{id})/ do
        #   groups Operator, Name::Attribute
        # end
      
      # rule %r/#{id}:/, Name::Label
      rule const_name, Name::Constant
      rule class_name, Name::Class
      rule %r/\$?#{id}/, Name
      rule %r/[~^*!%&\[\](){}<>\|+=:;,.\/?-]/, Operator
      
      digit = /[0-9]_+[0-9]|[0-9]/
      bin_digit = /[01]_+[01]|[01]/
      oct_digit = /[0-7]_+[0-7]|[0-7]/
      hex_digit = /[0-9a-f]_+[0-9a-f]|[0-9a-f]/i
      rule %r/#{digit}+\.#{digit}+([eE]#{digit}+)?[fd]?/, Num::Float, :worldDecl
      rule %r/0b#{bin_digit}+/i, Num::Bin, :worldDecl
      rule %r/0x#{hex_digit}+/i, Num::Hex, :worldDecl
      rule %r/0#{oct_digit}+/, Num::Oct, :worldDecl
      rule %r/#{digit}+L?/, Num::Integer, :worldDecl
      rule %r/\n/, Text
    end
    
    state :class do
      rule %r/\s+/m, Text
      rule id, Name::Class, :worldDecl
    end

    state :import do
      rule %r/\s+/m, Text
      rule %r/[a-z0-9_.]+\*?/i, Name::Namespace, :pop!
    end

    state :worldDecl do
      rule %r/\s+/m, Text
      rule atWorld, Name::Namespace
      rule %r/\(/m, Text, :multiWorldDecl
      rule id, Name::Namespace, :root
    end

    state :worldDeclWithoutAt do
      rule %r/\s+/m, Text
      rule %r/\(/m, Text, :multiWorldDecl
      rule id, Name::Namespace, :root
    end

    state :multiWorldDecl do
      rule id, Name::Namespace
      rule %r/,/m, Text
      rule %r/\)/m, Text, :root
    end

    state :multiWorldProDecl do
      rule id, Name::Namespace
      rule %r/,/m, Text
      rule %r/\]/m, Text, :root
    end

    state :worldDeclOrProd do
      rule %r/\s+/m, Text
      rule atWorld, Name::Namespace
      rule id, Name::Namespace, :root
      rule %r/\[/m, Text, :multiWorldProDecl
      rule %r/\(/m, Text, :multiWorldDecl
    end

    state :access do
      rule %r/\s+/m, Text
      rule %r/</m, Text, :generics
      rule id, Name::Attribute, :pop!
    end

    state :generics do
      rule %r/\s+/m, Text
      rule id, Name
      rule %r/</m, Text, :generics
      rule %r/,/m, Text
      rule %r/>/m, Text, :pop!
    end

    end
  end
end