require 'rake'
require 'rake/clean'
require 'rake/testtask'

CLEAN.include("**/*.tar", "**/*.zip", "**/*.gz", "**/*.bz2")
CLEAN.include("**/*.rbc", "**/*.gem", "**/*.tmp")

namespace "gem" do
  desc "Build the github_reports gem"
  task :build => [:clean] do
    require "rubygems/package"
    spec = eval(IO.read("github_reports.gemspec"))
    Gem::Package.build(spec)
  end

  desc "Install the github_reports gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

Rake::TestTask.new do |t|
  t.test_files = ["test/test*.rb"]
  t.verbose = true
  t.warning = true
end

task :default => :"gem:build"
