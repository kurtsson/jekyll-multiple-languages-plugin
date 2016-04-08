=begin
Jekyll Multiple Languages is an internationalization plugin for Jekyll. It
compiles your Jekyll site for one or more languages with a similar approach as
Rails does. The different sites will be stored in sub folders with the same name
as the language it contains.

Please visit https://github.com/screeninteraction/jekyll-multiple-languages-plugin
for more details.
=end


require "jekyll/multiple/languages/plugin/version"
require "colorator"

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



#===============================================================================
  # Boolean that stores if the _posts folder will not be included for localizations
  # True if it is not included, false otherwise.
  @translateposts = true
  
  #======================================
  # self.transposts
  #
  # Returns if _posts folder will not be included for localizations
  #======================================
  def self.transposts
    @translateposts
  end

  #======================================
  # self.settransposts
  #
  # Set the _posts folder will not be included for localizations
  #======================================
  def self.settransposts(t)
    @translateposts = t
  end



#===============================================================================
  # The current language that is being processed.
  @currentlanguage = ""
  
  #======================================
  # self.currlang
  #
  # Returns the current language being processed.
  #======================================
  def self.currlang
    @currentlanguage
  end

  #======================================
  # self.currlang
  #
  # Set the current language being processed.
  #======================================
  def self.setcurrlang(l)
    @currentlanguage = l
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
      
      if !self.config['exclude_from_localizations']
          self.config['exclude_from_localizations'] = []
      end
      
      if !self.config['languages'] or !self.config['languages'].any?
          puts "Jekyll Multiple Languages: ".bold + "You must provide at least one language using the 'languages' setting on your _config.yml.".red
          exit
      end
      
      
      # Variables
      #-------------------------------------------------------------------------
      config['baseurl_root'] = self.config[ 'baseurl' ] # baseurl set on _config.yml
      baseurl_org            = self.config[ 'baseurl' ] # baseurl set on _config.yml
      languages              = self.config['languages'] # List of languages set on _config.yml
      exclude_org            = self.exclude             # List of excluded paths
      dest_org               = self.dest                # Destination folder where the website is generated
      
      Jekyll.settransposts(!self.config['exclude_from_localizations'].include?("_posts"))
      
      
      
      # Build the website for default language
      #-------------------------------------------------------------------------
      self.config['lang'] = self.config['default_lang'] = languages.first
      
      Jekyll.setcurrlang(self.config['lang'])
      
      puts
      puts "Jekyll Multiple Languages: ".bold + "Building site for default language: \"#{self.config['lang']}\" to: #{self.dest}".blue
      
      process_org
      
      # Remove .htaccess file from included files, so it wont show up on translations folders.
      # https://github.com/screeninteraction/jekyll-multiple-languages-plugin/issues/47
      self.include -= [".htaccess"]
      
      # Build the website for the other languages
      #.........................................................................
      languages.drop(1).each do |lang|

        # Build site for language lang
        @dest                  = @dest                  + "/" + lang
        self.config['baseurl'] = self.config['baseurl'] + "/" + lang
        self.config['lang']    =                                lang

        # exclude folders or files from being copied to all the language folders
        exclude_from_localizations = self.config['exclude_from_localizations']
        @exclude                   =   @exclude + exclude_from_localizations

        Jekyll.setcurrlang(lang)

        puts "Jekyll Multiple Languages: ".bold + "Building site for language: \"#{self.config['lang']}\" to: #{self.dest}".blue
        process_org

        #Reset variables for next language
        @dest    =    dest_org
        @exclude = exclude_org

        self.config['baseurl'] = baseurl_org
      end
      
      Jekyll.setlangs(      {} )
      Jekyll.settransposts(true)
      Jekyll.setcurrlang(   "" )
      
      puts 'Build complete'.green
    end
    
    
    
    # For Jekyll version < 3. We check if this method is defined, this method
    # was deprecated on version 3+.
    if Site.method_defined?   :read_posts
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
    
  end



  ##############################################################################
  # class Reader
  ##############################################################################
  class Reader
    # For Jekyll version 3+. We check if this method is defined, this method
    # replaces the deprecated read_posts method used on old versions.
    if Reader.method_defined?   :retrieve_posts
      alias :retrieve_posts_org :retrieve_posts
      
      #======================================
      # retrieve_posts
      #======================================
      def retrieve_posts(dir)
        if dir == '' && Jekyll.transposts
          site.posts.docs.concat(PostReader.new(site).read_posts( "_i18n/#{Jekyll.currlang}/"))
          site.posts.docs.concat(PostReader.new(site).read_drafts("_i18n/#{Jekyll.currlang}/")) if site.show_drafts
        else
          retrieve_posts_org(dir)
        end
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
        puts "Jekyll Multiple Languages: ".bold + "Loading translation from file #{context.registers[:site].source}/_i18n/#{lang}.yml".blue
        Jekyll.langs[lang] = YAML.load_file(                                    "#{context.registers[:site].source}/_i18n/#{lang}.yml")
      end
      
      translation = Jekyll.langs[lang].access(key) if key.is_a?(String)
      
      if translation.nil? or translation.empty?
         translation = Jekyll.langs[context.registers[:site].config['default_lang']].access(key)
        
        puts "Jekyll Multiple Languages: ".bold + "Missing i18n key: #{lang}:#{key}".yellow
        puts "Using translation '%s' from default language: %s" %[translation, context.registers[:site].config['default_lang']].yellow
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
          puts "Jekyll Multiple Languages: ".bold + "Includes directory '#{includes_dir}' cannot be a symlink".red
          return                                    "Includes directory '#{includes_dir}' cannot be a symlink"
        end
        
        if file !~ /^[a-zA-Z0-9_\/\.-]+$/ || file =~ /\.\// || file =~ /\/\./
          puts "Jekyll Multiple Languages: ".bold + "Include file '#{file}' contains invalid characters or sequences".red
          return                                    "Include file '#{file}' contains invalid characters or sequences"
        end

        Dir.chdir(includes_dir) do
          choices = Dir['**/*'].reject { |x| File.symlink?(x) }
          
          if choices.include?(file)
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
            puts "Jekyll Multiple Languages: ".bold + "Included file '#{file}' not found in #{includes_dir} directory".red
            return                                    "Included file '#{file}' not found in #{includes_dir} directory"
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
  
  
  
  ##############################################################################
  # class Hash
  ##############################################################################
  class Post
    # For Jekyll version < 3. We check if this method is defined, this method
    # replaces the deprecated populate_categories method used on old versions.
    if Post.method_defined?   :populate_categories
      alias :populate_categories_org :populate_categories
      
      #======================================
      # populate_categories
      #======================================
      def populate_categories
        cats = Array(categories);

        x = cats.index("_i18n")
        cats.delete_at(x) unless x.nil?

        x = cats.index(site.config['lang'])
        cats.delete_at(x) unless x.nil?

        self.categories = cats

        populate_categories_org
      end
    end
  end
  
  
end # End module Jekyll



################################################################################
# class Hash
################################################################################
unless Hash.method_defined? :access
  class Hash
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
