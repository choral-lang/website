Jekyll::Hooks.register :site, :after_init do | site |
  require "rouge"
  load( "#{site.source}/_rogue/choral_lexer.rb" )
  ::Rouge::Lexer.instance_variable_get(:@registry)[::Rouge::Lexers::Choral.tag] = ::Rouge::Lexers::Choral
end