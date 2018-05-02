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

    class PathEquivalent
      def initialize exclude_path, static_path
        @exclude_path = exclude_path
        @static_path = static_path
      end

      def check
        # <=> Spaceship operator
        # retun 0 if 2 operator are ==
        result = Pathname.new(@exclude_path) <=> @static_path
        return true if result == 0
        false
      end
    end
  end
end
