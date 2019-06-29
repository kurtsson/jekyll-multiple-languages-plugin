require "bundler/gem_tasks"
require "html-proofer"


#######################################
# default
#######################################
task :default => [:test]



#######################################
# test
#######################################
# A simple test which buils the example site.
desc "Run tests"
task :test do
  cd "example" do
    sh "bundle exec jekyll build"
    options = { empty_alt_ignore: true }
    HTMLProofer.check_directory("./_site", options).run
  end
end
