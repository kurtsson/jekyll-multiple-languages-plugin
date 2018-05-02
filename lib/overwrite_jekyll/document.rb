module Jekyll
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
end
