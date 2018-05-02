=begin

Jekyll  Multiple  Languages  is  an  internationalization  plugin for Jekyll. It
compiles  your  Jekyll site for one or more languages with a similar approach as
Rails does. The different sites will be stored in sub folders with the same name
as the language it contains.

Please visit https://github.com/screeninteraction/jekyll-multiple-languages-plugin
for more details.

=end

require_relative 'plugin/version'
require_relative 'overwrite_jekyll/site'
require_relative 'overwrite_jekyll/page'
require_relative 'overwrite_jekyll/post'
require_relative 'overwrite_jekyll/post_reader'
require_relative 'overwrite_jekyll/document'
require_relative 'overwrite_jekyll/hash_custom'

require_relative 'custom_tags'
require_relative 'tools/path_equivalent'
require_relative 'tools/remover'

module Jekyll

  Jekyll::Hooks.register(:site, :post_render) do |site, payload|

    default_lang  = payload["site"]["default_lang"]
    current_lang  = payload["site"]["lang"]

    static_files  = payload["site"]["static_files"]
    exclude_paths = payload["site"]["exclude_from_localizations"]
    pages         = payload["site"]["pages"]


    if default_lang != current_lang
      static_files.delete_if do |static_file|
        # static_file is a Jekyll::StaticFile
        # Remove "/" from beginning of static file relative path
        static_file_relative_path    = static_file.instance_variable_get(:@relative_path).dup
        static_file_relative_path[0] = ''
        MultipleLanguagePluginTools::RemoverStaticFiles.go static_file_relative_path, exclude_paths
      end

      pages.delete_if do |page|
        exclude_paths.include? page.name
      end
    end

  end

end
