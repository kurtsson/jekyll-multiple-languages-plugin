module Jekyll

  class Post

    if Gem::Version.new(Jekyll::VERSION) < Gem::Version.new("3.0.0")
      alias :populate_categories_org :populate_categories

      #======================================
      # populate_categories
      #
      # Monkey patched this method to remove unwanted strings
      # ("_i18n" and language code) that are prepended to posts categories
      # because of how the multilingual posts are arranged in subfolders.
      #======================================
      def populate_categories
        categories_from_data = Utils.pluralized_array_from_hash(data, 'category', 'categories')
        self.categories = (
          Array(categories) + categories_from_data
        ).map {|c| c.to_s.downcase}.flatten.uniq

        self.categories.delete("_i18n")
        self.categories.delete(site.config['lang'])

        return self.categories
      end
    end
  end

end
