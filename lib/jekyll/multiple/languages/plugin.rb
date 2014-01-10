require "jekyll/multiple/languages/plugin/version"

module Jekyll
  class Site
    alias :process_org :process
    def process
      if !self.config['baseurl']
        self.config['baseurl'] = ""
      end
      #Variables
      config['baseurl_root'] = self.config['baseurl']
      baseurl_org = self.config['baseurl']
      languages = self.config['languages']
      dest_org = self.dest

      #Loop
      self.config['lang'] = languages.first
      puts
      puts "Building site for default language: \"#{self.config['lang']}\" to: " + self.dest
      process_org
      languages.drop(1).each do |lang|

        # Build site for language lang
        self.dest = self.dest + "/" + lang
        self.config['baseurl'] = self.config['baseurl'] + lang + "/"
        self.config['lang'] = lang
        puts "Building site for language: \"#{self.config['lang']}\" to: " + self.dest
        process_org

        #Reset variables for next language
        self.dest = dest_org
        self.config['baseurl'] = baseurl_org
      end
      puts 'Build complete'
    end
    
    alias :read_posts_org :read_posts
    def read_posts(dir)
      if dir == ''
        posts = read_things("_i18n/#{self.config['lang']}","_posts", Post)
        posts.each do |post|
          post.categories = []
          if post.date != ''
            if post.published && (self.future || post.date <= self.time)
              aggregate_post_info(post)
            end
          end
        end
      else
        read_posts_org(dir)
      end
    end
  end

  class LocalizeTag < Liquid::Tag

    def initialize(tag_name, key, tokens)
      super
      @key = key.strip
    end

    def render(context)
      if "#{context[@key]}" != "" #Check for page variable
        key = "#{context[@key]}"
      else
        key = @key
      end
      lang = context.registers[:site].config['lang']
      candidate = YAML.load_file(context.registers[:site].source + "/_i18n/#{lang}.yml")
      path = key.split(/\./) if key.is_a?(String)
      while !path.empty?
        key = path.shift
        if candidate[key]
          candidate = candidate[key]
        else
          candidate = ""
        end
      end
      if candidate == ""
        puts "Missing i18n key: " + lang + ":" + key
        "*" + lang + ":" + key + "*"
      else
        candidate
      end
    end
  end

  module Tags
    class LocalizeInclude < IncludeTag
      def render(context)
        if "#{context[@file]}" != "" #Check for page variable
          file = "#{context[@file]}"
        else
          file = @file
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
          if choices.include?(file)
            source = File.read(file)
            partial = Liquid::Template.parse(source)

            context.stack do
              context['include'] = parse_params(context) if @params
              contents = partial.render(context)
              site = context.registers[:site]
              ext = File.extname(file)

              converter = site.converters.find { |c| c.matches(ext) }
              contents = converter.convert(contents) unless converter.nil?

              contents
            end
          else
            "Included file '#{file}' not found in #{includes_dir} directory"
          end
        end
      end
    end
  end
end

Liquid::Template.register_tag('t', Jekyll::LocalizeTag)
Liquid::Template.register_tag('translate', Jekyll::LocalizeTag)
Liquid::Template.register_tag('tf', Jekyll::Tags::LocalizeInclude)
Liquid::Template.register_tag('translate_file', Jekyll::Tags::LocalizeInclude)
