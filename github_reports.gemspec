require 'rubygems'

Gem::Specification.new do |spec|
  spec.name = "github_reports"
  spec.version = "0.1.0"
  spec.authors = ["Greg Blomquist"]
  spec.license = "Apache 2.0"
  spec.homepage = "http://github.com/blomquisg/github_reports"
  spec.summary = "A library that can run different reports against Github repositories"
  spec.test_file = "test/test_github_reports.rb"
  spec.files = Dir["**/*"].delete_if {|item| item.include?("git") }

  spec.bindir = "bin"
  spec.executables = "github_report_runner"

  spec.extra_rdoc_files = ["CHANGES", "README.md"]

  spec.add_dependency("json")
  spec.add_dependency("rest-client")
  spec.add_dependency("erubis")

  spec.description = <<-EOF
    GithubReports is a library for creating various reports against a Github repository.
  EOF
end
