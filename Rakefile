require "bundler/gem_tasks"



#######################################
# default
#######################################
task :default => [:test]



#######################################
# test
#######################################
# A simple test which buils the example site.
desc "Run tests"

task :build do
  cd "example" do
    sh "bundle exec jekyll build"
  end
end

task :test do
  sh "ruby test/base_test.rb"
end
