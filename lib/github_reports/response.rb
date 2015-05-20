require 'json'

module GithubReports
  module Response
    attr_reader :json

    def self.extended(response)
      raise ArgumentError.new("Invalid response type: #{response.class}") unless response.is_a? RestClient::Response
      response.init_json
    end

    def init_json
      @json = JSON.parse body
      self
    end

    def rate_limit
      headers[:x_ratelimit_limit]
    end

    def rate_limit_remaining
      headers[:x_ratelimit_remaining]
    end
  end
end
