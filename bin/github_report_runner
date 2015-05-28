#!/bin/env ruby

require 'github_reports'

def usage(error)
  "Usage: #{__FILE__} report_filename [arg1, [arg2, ...]"
  exit(1) if error
end

usage(true) if ARGV.size == 0

#TODO: Currently this assumes only one type of report ... maybe there's a clever
#      way to embed the creation of the report model in the ERB directly?
report_filename = ARGV.shift
report = GithubReports::Runner.run(report_filename, *ARGV) do |report_model, *args|
  label = args[0] if args.size > 0
  report_model[:pull_requests] = GithubReports::Api.find_pull_requests(label)
end

puts report
