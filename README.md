## Github Reports

A simple library for creating reports for Github Pull Requests.

### Example

```ruby
require 'github_reports'

report = GithubReports::Runner.run("reports/pull_request_report_sample.erb") do |model|
  model[:pull_requests] = GithubReports::Api.find_pull_requests("my_label")
end

puts report
```
