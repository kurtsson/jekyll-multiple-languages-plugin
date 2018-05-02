require "bundler/gem_tasks"

task :default => [:test]

desc "Run tests"

task :build do
  cd "example" do
    sh "bundle exec jekyll build"
  end
end

task :test do
  sh "ruby test/base_test.rb"
end
