# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll/multiple/languages/plugin/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyll-multiple-languages-plugin"
  spec.version       = Jekyll::Multiple::Languages::Plugin::VERSION
  spec.authors       = ["Martin Kurtsson"]
  spec.email         = ["martin.kurtsson@screeninteraction.com"]
  spec.description   = %q{Plugin for Jekyll and Octopress that adds support for translated keys, templates and posts.}
  spec.summary       = %q{I18n plugin for Jekyll and Octopress}
  spec.homepage      = "https://github.com/screeninteraction/jekyll-multiple-languages-plugin/"
  spec.license       = "MPL2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 0"
  
  spec.add_runtime_dependency "colorator"
end
