require 'minitest/autorun'
require 'minitest/pride'
require './lib/tools.rb'

module Jekyll
  module MultipleLanguagePluginTools
    class TestTools < Minitest::Test

      def test_delete_from_array
        static_files  = ['file.jpeg', 'file.txt', '/relative_path.pdf'].map{|value| Pathname.new(value)}
        exclude_paths = ['file.jpeg']
        static_files.delete_if do |static_file|
          Remover.go static_file, exclude_paths
        end
        assert_equal static_files, ['file.txt', '/relative_path.pdf'].map{|value| Pathname.new(value)}
      end

      def test_path_are_the_same
        equivalent_tool = PathEquivalent.new('file.rb', Pathname.new('file.rb'))
        assert equivalent_tool.check
      end

    end
  end
end
