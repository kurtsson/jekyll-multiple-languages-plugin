require 'minitest/autorun'
require 'minitest/pride'
require 'jekyll'
require './lib/jekyll-multiple-languages-plugin.rb'
class TestMeme < Minitest::Test
  def setup
    #exclude_path = 'file.rb'
    # Pathname.new('/path/to/some/file.rb').descend do |static_file_path|
    #   @remover = Jekyll::FileRemover.new(exclude_path, static_file_path)
    # end
  end

  def test_that_kitty_can_eat
    static_path = Pathname.new('file.rb')
    equivalent_tool = Jekyll::PathEquivalentTool.new('file.rb', static_path)
    assert equivalent_tool.check
  end
  #
  # def test_that_it_will_not_blend
  #   refute_match /^no/i, @meme.will_it_blend?
  # end
  #
  # def test_that_will_be_skipped
  #   skip "test this later"
  # end
end
