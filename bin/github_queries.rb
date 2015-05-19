require 'github_api'

def find_pull_requests(label = nil, state = 'open')
  github = Github.new
  query = build_query(label)
  return github.search.issues(:q => query).body.items, query
end

## helpers
def build_query(label = nil, type = "pr", state = "open", repo = "ManageIQ/manageiq")
  query = "type:#{type}+is:#{state}+repo:#{repo}"
  query = "#{query}+label:#{label}" if label
  query
end

## comman line helpers
PR_STATES = %w(open closed merged)
def parse_command_line(args)
  require 'optparse'
  require 'ostruct'

  options = OpenStruct.new
  parser = OptionParser.new do |opts|
    opts.separator ""
    opts.separator "Options: "

    # eventually, might want to include different "actions" on the command line
    # with individualized help for each action .. each action could correspond
    # to a top level function (find_pull_requests, for instance)
    opts.banner = "Usage: #{$0} [label] [state]"

    opts.on("-l", "--label [LABEL]", "Pull Request Label to filter on") do |label|
      options.label = label
    end

    opts.on("-s", "--state [STATE]", PR_STATES, "Pull Requets State to filter on") do |state|
      options.state = state
    end
  end

  parser.parse!(args)
  options
end

def query_string_to_english(query_string = "")
  query_hash = {}
  # collect values together under the same keys:
  #   i.e., Label: one, two, three
  query_string.split("+").each do |key_value|
    key, value = key_value.split(":")
    value = [query_hash[key], value].join(", ") if query_hash.key? key
    query_hash[key] = value
  end

  query_hash.each.collect do |key, value|
    [key, value].join(": ")
  end
end

def print_pull_requests(pull_requests = [], query_string = "")
  header = "Pull requests"
  header = "#{header} from query [#{query_string_to_english(query_string)}]" if query_string > ""
  header = "#{header} (#{pull_requests.size})"

  puts header
  pull_requests.each do |pr|
    puts "#{pr.number}: #{pr.title}"
  end
end

def run!
  options = parse_command_line(ARGV)
  pull_requests, query_string = find_pull_requests(options.label, options.state)
  print_pull_requests(pull_requests, query_string)
end
run! if __FILE__==$0
