=begin

Jekyll  Multiple  Languages  is  an  internationalization  plugin for Jekyll. It
compiles  your  Jekyll site for one or more languages with a similar approach as
Rails does. The different sites will be stored in sub folders with the same name
as the language it contains.

Please visit https://github.com/screeninteraction/jekyll-multiple-languages-plugin
for more details.

=end

require_relative 'plugin/version'
require_relative 'jekyll_plugin/site'
require_relative 'jekyll_plugin/page'
require_relative 'jekyll_plugin/post'
require_relative 'jekyll_plugin/post_reader'

require_relative 'tools'

module Jekyll

  #*****************************************************************************
  # :site, :post_render hook
  #*****************************************************************************
  Jekyll::Hooks.register(:site, :post_render) do |site, payload|

    # Removes all static files that should not be copied to translated sites.
    #===========================================================================
    default_lang  = payload["site"]["default_lang"]
    current_lang  = payload["site"]["lang"]

    static_files  = payload["site"]["static_files"]
    exclude_paths = payload["site"]["exclude_from_localizations"]

    if default_lang != current_lang
      static_files.delete_if do |static_file|
        # static_file is a Jekyll::StaticFile
        # Remove "/" from beginning of static file relative path
        static_file_relative_path    = static_file.instance_variable_get(:@relative_path).dup
        static_file_relative_path[0] = ''
        MultipleLanguagePluginTools::Remover.go static_file_relative_path, exclude_paths
      end
    end

    #===========================================================================

  end


  ##############################################################################
  # class Document
  ##############################################################################
  class Document

    if Gem::Version.new(Jekyll::VERSION) >= Gem::Version.new("3.0.0")
      alias :populate_categories_org :populate_categories

      #======================================
      # populate_categories
      #
      # Monkey patched this method to remove unwanted strings
      # ("_i18n" and language code) that are prepended to posts categories
      # because of how the multilingual posts are arranged in subfolders.
      #======================================
      def populate_categories
        data['categories'].delete("_i18n")
        data['categories'].delete(site.config['lang'])

        merge_data!({
          'categories' => (
            Array(data['categories']) + Utils.pluralized_array_from_hash(data, 'category', 'categories')
          ).map(&:to_s).flatten.uniq
        })
      end
    end
  end



  #-----------------------------------------------------------------------------
  #
  # The next classes implements the plugin Liquid Tags and/or Filters
  #
  #-----------------------------------------------------------------------------


  ##############################################################################
  # class LocalizeTag
  #
  # Localization by getting localized text from YAML files.
  # User must use the "t" or "translate" liquid tags.
  ##############################################################################
  class LocalizeTag < Liquid::Tag

    #======================================
    # initialize
    #======================================
    def initialize(tag_name, key, tokens)
      super
      @key = key.strip
    end



    #======================================
    # render
    #======================================
    def render(context)
      if      "#{context[@key]}" != "" # Check for page variable
        key = "#{context[@key]}"
      else
        key =            @key
      end

      key = Liquid::Template.parse(key).render(context)  # Parses and renders some Liquid syntax on arguments (allows expansions)

      site = context.registers[:site] # Jekyll site object

      lang = site.config['lang']

      unless site.parsed_translations.has_key?(lang)
        puts              "Loading translation from file #{site.source}/_i18n/#{lang}.yml"
        site.parsed_translations[lang] = YAML.load_file("#{site.source}/_i18n/#{lang}.yml")
      end

      translation = site.parsed_translations[lang].access(key) if key.is_a?(String)

      if translation.nil? or translation.empty?
         translation = site.parsed_translations[site.config['default_lang']].access(key)

        puts "Missing i18n key: #{lang}:#{key}"
        puts "Using translation '%s' from default language: %s" %[translation, site.config['default_lang']]
      end

      translation
    end
  end



  ##############################################################################
  # class LocalizeInclude
  #
  # Localization by including whole files that contain the localization text.
  # User must use the "tf" or "translate_file" liquid tags.
  ##############################################################################
  module Tags
    class LocalizeInclude < IncludeTag

      #======================================
      # render
      #======================================
      def render(context)
        if       "#{context[@file]}" != "" # Check for page variable
          file = "#{context[@file]}"
        else
          file =            @file
        end

        file = Liquid::Template.parse(file).render(context)  # Parses and renders some Liquid syntax on arguments (allows expansions)

        site = context.registers[:site] # Jekyll site object

        includes_dir = File.join(site.source, '_i18n/' + site.config['lang'])

        validate_file_name(file)

        Dir.chdir(includes_dir) do
          choices = Dir['**/*'].reject { |x| File.symlink?(x) }

          if choices.include?(  file)
            source  = File.read(file)
            partial = Liquid::Template.parse(source)

            context.stack do
              context['include'] = parse_params(  context) if @params
              contents           = partial.render(context)
              ext                = File.extname(file)

              converter = site.converters.find { |c| c.matches(ext) }
              contents  = converter.convert(contents) unless converter.nil?

              contents
            end
          else
            raise IOError.new "Included file '#{file}' not found in #{includes_dir} directory"
          end

        end
      end
    end
  end



  ##############################################################################
  # class LocalizeLink
  #
  # Creates links or permalinks for translated pages.
  # User must use the "tl" or "translate_link" liquid tags.
  ##############################################################################
  class LocalizeLink < Liquid::Tag

    #======================================
    # initialize
    #======================================
    def initialize(tag_name, key, tokens)
      super
      @key = key
    end



    #======================================
    # render
    #======================================
    def render(context)
      if      "#{context[@key]}" != "" # Check for page variable
        key = "#{context[@key]}"
      else
        key = @key
      end

      key = Liquid::Template.parse(key).render(context)  # Parses and renders some Liquid syntax on arguments (allows expansions)

      site = context.registers[:site] # Jekyll site object

      key          = key.split
      namespace    = key[0]
      lang         = key[1] || site.config[        'lang']
      default_lang =           site.config['default_lang']
      baseurl      =           site.baseurl
      pages        =           site.pages
      url          = "";

      if default_lang != lang
        baseurl = baseurl + "/" + lang
      end

      for p in pages
        unless             p['namespace'].nil?
          page_namespace = p['namespace']

          if namespace == page_namespace
            permalink = p['permalink_'+lang] || p['permalink']
            url       = baseurl + permalink
          end
        end
      end

      url
    end
  end


end # End module Jekyll



################################################################################
# class Hash
################################################################################
unless Hash.method_defined? :access
  class Hash

    #======================================
    # access
    #======================================
    def access(path)
      ret = self

      path.split('.').each do |p|

        if p.to_i.to_s == p
          ret = ret[p.to_i]
        else
          ret = ret[p.to_s] || ret[p.to_sym]
        end

        break unless ret
      end

      ret
    end
  end
end



################################################################################
# Liquid tags definitions

Liquid::Template.register_tag('t',              Jekyll::LocalizeTag          )
Liquid::Template.register_tag('translate',      Jekyll::LocalizeTag          )
Liquid::Template.register_tag('tf',             Jekyll::Tags::LocalizeInclude)
Liquid::Template.register_tag('translate_file', Jekyll::Tags::LocalizeInclude)
Liquid::Template.register_tag('tl',             Jekyll::LocalizeLink         )
Liquid::Template.register_tag('translate_link', Jekyll::LocalizeLink         )
