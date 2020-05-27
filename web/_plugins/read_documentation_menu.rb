module Jekyll
  class DocumentationMenu < Generator
    priority :highest

    def generate(site)
      base = "#{site.source}/_documentation"
      Dir["#{base}/_menu.yaml"].each do | f |
        site.data[ "documentation_menu" ] = YAML.load( File.read( f ) )
      end
    end
  end
end