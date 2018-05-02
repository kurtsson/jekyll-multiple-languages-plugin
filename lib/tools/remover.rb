module Jekyll
  module MultipleLanguagePluginTools

    class Remover
      def self.go static_file_relative_path, exclude_paths
        exclude_paths.any? do |exclude_path|
          Pathname.new(static_file_relative_path).descend do |static_file_path|
            path_equivalent_tool = PathEquivalent.new(exclude_path, static_file_path)
            break(true) if path_equivalent_tool.check
          end
        end
      end
    end
    
  end
end
