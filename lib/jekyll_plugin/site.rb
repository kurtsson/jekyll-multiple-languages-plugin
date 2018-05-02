module Jekyll
  
  ##############################################################################
  # class Site
  ##############################################################################
  class Site

    attr_accessor :parsed_translations   # Hash that stores parsed translations read from YAML files.

    alias :process_org :process

    #======================================
    # process
    #
    # Reads Jekyll and plugin configuration parameters set on _config.yml, sets
    # main parameters and processes the website for each language.
    #======================================
    def process
      # Check if plugin settings are set, if not, set a default or quit.
      #-------------------------------------------------------------------------
      self.parsed_translations ||= {}

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

      # Original Jekyll configurations
      baseurl_org                 = self.config[ 'baseurl' ] # Baseurl set on _config.yml
      dest_org                    = self.dest                # Destination folder where the website is generated

      # Site building only variables
      languages                   = self.config['languages'] # List of languages set on _config.yml

      # Site wide plugin configurations
      self.config['default_lang'] = languages.first          # Default language (first language of array set on _config.yml)
      self.config[        'lang'] = languages.first          # Current language being processed
      self.config['baseurl_root'] = baseurl_org              # Baseurl of website root (without the appended language code)
      self.config['translations'] = self.parsed_translations # Hash that stores parsed translations read from YAML files. Exposes this hash to Liquid.


      # Build the website for default language
      #-------------------------------------------------------------------------
      puts "Building site for default language: \"#{self.config['lang']}\" to: #{self.dest}"

      process_org


      # Build the website for the other languages
      #-------------------------------------------------------------------------

      # Remove .htaccess file from included files, so it wont show up on translations folders.
      self.include -= [".htaccess"]

      languages.drop(1).each do |lang|

        # Language specific config/variables
        @dest                  = dest_org    + "/" + lang
        self.config['baseurl'] = baseurl_org + "/" + lang
        self.config['lang']    =                     lang

        puts "Building site for language: \"#{self.config['lang']}\" to: #{self.dest}"

        process_org
      end

      # Revert to initial Jekyll configurations (necessary for regeneration)
      self.config[ 'baseurl' ] = baseurl_org  # Baseurl set on _config.yml
      @dest                    = dest_org     # Destination folder where the website is generated

      puts 'Build complete'
    end



    if Gem::Version.new(Jekyll::VERSION) < Gem::Version.new("3.0.0")
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
end
