module Jekyll
  module MultipleLanguagePluginTools
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
