module Jekyll
  module MultipleLanguagePluginTools

    class Remover
      def self.go static_file_relative_path, excluded_paths
        excluded_paths.any? do |excluded_path|
          same_path?(static_file_relative_path, excluded_path)
        end
      end

      private

      def self.same_path? static_file_relative_path, excluded_path
        Pathname.new(static_file_relative_path).descend do |static_file_path|
          path_equivalent_tool = PathEquivalent.new(excluded_path, static_file_path)
          break(true) if path_equivalent_tool.check
        end
      end
    end

  end
end
