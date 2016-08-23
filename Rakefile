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
task :test do
  cd "example" do
    sh "bundle exec jekyll build"
  end
end
