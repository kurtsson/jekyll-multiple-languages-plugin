module Jekyll
  class PostReader

    if Gem::Version.new(Jekyll::VERSION) >= Gem::Version.new("3.0.0")
      alias :read_posts_org :read_posts

      def read_posts(dir)
        translate_posts = !site.config['exclude_from_localizations'].include?("_posts")
        if dir == '' && translate_posts
          read_posts("_i18n/#{site.config['lang']}/")
        else
          read_posts_org(dir)
        end
      end
    end

  end

end
