module Jekyll
  class Page

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
end
