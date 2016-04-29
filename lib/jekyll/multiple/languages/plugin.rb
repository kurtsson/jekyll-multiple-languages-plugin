=begin

Jekyll  Multiple  Languages  is  an  internationalization  plugin for Jekyll. It
compiles  your  Jekyll site for one or more languages with a similar approach as
Rails does. The different sites will be stored in sub folders with the same name
as the language it contains.

Please visit https://github.com/screeninteraction/jekyll-multiple-languages-plugin
for more details.

=end



require "jekyll/multiple/languages/plugin/version"

module Jekyll
  # Hash that stores a list of language translations read from an YAML file.
  @parsedlangs = {}

  #======================================
  # self.langs
  #
  # Returns the list of translations.
  #======================================
  def self.langs
    @parsedlangs
  end

  #======================================
  # self.setlangs
  #
  # Set the list of translations.
  #======================================
  def self.setlangs(l)
    @parsedlangs = l
  end



  ##############################################################################
  # class Site
  ##############################################################################
  class Site
  
    alias :process_org :process
    
    #======================================
    # process
    #
    # Reads Jekyll and plugin configuration parameters set on _config.yml, sets
    # main parameters and processes the website for each language.
    #======================================
    def process
      # Check if some importat settings are set, if not, set a default or quit.
      #-------------------------------------------------------------------------
      if !self.config['baseurl']
          self.config['baseurl'] = ""
      end
      
      self.config['exclude_from_localizations'] ||= []
      
      if ( !self.config['languages']         or
            self.config['languages'].empty?  or
           !self.config['languages'].all?
         )
          puts 'You must provide at least one language using the "languages" setting on your _config.yml.'
          
          exit
      end
      
      
      # Variables
      #-------------------------------------------------------------------------
      config['baseurl_root'] = self.config[ 'baseurl' ] # baseurl set on _config.yml
      baseurl_org            = self.config[ 'baseurl' ] # baseurl set on _config.yml
      languages              = self.config['languages'] # List of languages set on _config.yml
      exclude_org            = self.exclude             # List of excluded paths
      dest_org               = self.dest                # Destination folder where the website is generated
      
      
      # Build the website for default language
      #-------------------------------------------------------------------------
      self.config['lang'] = self.config['default_lang'] = languages.first
      puts
      puts "Building site for default language: \"#{self.config['lang']}\" to: #{self.dest}"
      
      process_org
      
      # Remove .htaccess file from included files, so it wont show up on translations folders.
      self.include -= [".htaccess"]
      
      # Build the website for the other languages
      #-------------------------------------------------------------------------
      languages.drop(1).each do |lang|
        
        # Build site for language lang
        @dest                  = @dest                  + "/" + lang
        self.config['baseurl'] = self.config['baseurl'] + "/" + lang
        self.config['lang']    =                                lang
        
        # exclude folders or files from being copied to all the language folders
        exclude_from_localizations = self.config['exclude_from_localizations'] || []
        @exclude                   =   @exclude + exclude_from_localizations
        
        puts "Building site for language: \"#{self.config['lang']}\" to: #{self.dest}"
        process_org
        
        #Reset variables for next language
        @dest    =    dest_org
        @exclude = exclude_org
        
        self.config['baseurl'] = baseurl_org
      end
      
      Jekyll.setlangs({})
      
      puts 'Build complete'
    end



    alias :read_posts_org :read_posts

    #======================================
    # read_posts
    #======================================
    def read_posts(dir)
      translate_posts = !self.config['exclude_from_localizations'].include?("_posts")
      
      if dir == '' && translate_posts
        read_posts("_i18n/#{self.config['lang']}/")
      else
        read_posts_org(dir)
      end
      
    end
  end



  ##############################################################################
  # class Page
  ##############################################################################
  class Page
  
    #======================================
    # permalink
    #======================================
    def permalink
      return nil if data.nil? || data['permalink'].nil?
      
      if site.config['relative_permalinks']
        File.join(@dir,  data['permalink'])
      else
        # Look if there's a permalink overwrite specified for this lang
        data['permalink_'+site.config['lang']] || data['permalink']
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
      
      lang = context.registers[:site].config['lang']
      
      unless Jekyll.langs.has_key?(lang)
        puts  "Loading translation from file #{context.registers[:site].source}/_i18n/#{lang}.yml"
        Jekyll.langs[lang] = YAML.load_file("#{context.registers[:site].source}/_i18n/#{lang}.yml")
      end
      
      translation = Jekyll.langs[lang].access(key) if key.is_a?(String)
      
      if translation.nil? or translation.empty?
         translation = Jekyll.langs[context.registers[:site].config['default_lang']].access(key)
        
        puts "Missing i18n key: #{lang}:#{key}"
        puts "Using translation '%s' from default language: %s" %[translation, context.registers[:site].config['default_lang']]
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
        
        includes_dir = File.join(context.registers[:site].source, '_i18n/' + context.registers[:site].config['lang'])
        
        if File.symlink?(includes_dir)
          return "Includes directory '#{includes_dir}' cannot be a symlink"
        end
        
        if file !~ /^[a-zA-Z0-9_\/\.-]+$/ || file =~ /\.\// || file =~ /\/\./
          return "Include file '#{file}' contains invalid characters or sequences"
        end
        
        Dir.chdir(includes_dir) do
          choices = Dir['**/*'].reject { |x| File.symlink?(x) }
          
          if choices.include?(  file)
            source  = File.read(file)
            partial = Liquid::Template.parse(source)
            
            context.stack do
              context['include'] = parse_params(  context) if @params
              contents           = partial.render(context)
              site               = context.registers[:site]
              ext                = File.extname(file)
              
              converter = site.converters.find { |c| c.matches(ext) }
              contents  = converter.convert(contents) unless converter.nil?
              
              contents
            end
          else
            "Included file '#{file}' not found in #{includes_dir} directory"
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
      
      key          = key.split
      namespace    = key[0]
      lang         = key[1] || context.registers[:site].config[        'lang']
      default_lang =           context.registers[:site].config['default_lang']
      baseurl      =           context.registers[:site].baseurl
      pages        =           context.registers[:site].pages
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

