require 'erubis'
require_relative 'api'

module GithubReports
  module Runner
    def self.run(erb_file, *args)
      raise ArgumentError.new("block required") unless block_given?

      # caller will create the report model hash
      yield @report_model = {}, *args
      Erubis::Eruby.new(File.read(erb_file)).result(binding)
    end
  end
end
