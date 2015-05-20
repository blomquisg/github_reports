require 'rest-client'
require_relative 'api/models'
require_relative 'response'
require_relative 'paged_response'

RESULTS_PER_PAGE = 100
MAX_RESULTS = 200

module GithubReports
  class TooManyResultsError < StandardError
    attr_reader :total_items, :url
    def initialize(total_items, url)
      @total_items  = total_items
      @url = url
      super "Too many results (#{total_items}) for request #{url}"
    end
  end

  module Api
    def self.config
      GithubReports::Config.instance
    end

    def self.find_pull_requests(label = nil, state = "open")
      options = {"type" => "pr", "is" => state, "repo" => config.repo}
      options["label"] = label if label
      response = search_issues(options)
      response.items.collect do |search_result|
        PullRequest.new(search_result) do |pull_request|
          pull_request.init_pr(query(pull_request.pr_url).json).
            init_comments(query(pull_request.comments_url).json).
            init_review_comments(query(pull_request.review_comments_url).json)
        end
      end
    end

    private

    # there are other options here, but only supporting these for now
    # https://developer.github.com/v3/search/#search-issues
    ISSUE_SEARCH_KEYS = %w(type is repo mentions label)
    def self.search_issues(options = {})
      url = "#{config.host}/search/issues"
      q = options.each.collect do |key, value|
        next unless ISSUE_SEARCH_KEYS.include? key
        "#{key}:#{value}"
      end.join("+")
      url = "#{url}?q=#{q}"
      response = paged_query(url)
    end

    def self.query(url)
      puts "Url: #{url}"
      response = raw_query(url)
      puts "   rate limit: #{response.rate_limit_remaining} of #{response.rate_limit} remaining"
      response
    end

    def self.paged_query(url)
      url = add_results_per_page_param(url, RESULTS_PER_PAGE)
      response = query(url).extend GithubReports::PagedResponse

      # bail on total count before trying to process any pages
      total_count = response.total_count
      raise TooManyResultsError.new(total_count, repsonse.request.url) if total_count > MAX_RESULTS

      # collect all pages
      combined_response = response
      while response.has_next_page?
        combined_response.append(query(response.next_page))
      end
      combined_response
    end

    def self.add_results_per_page_param(url, per_page)
      separator = url.include?("?") ? "&" : "?"
      "#{url}#{separator}per_page=#{per_page}"
    end

    def self.raw_query(url)
      # since this is a reporting lib, the only method will be :get
      params = {:url => url, :method => :get}
      if config.username && config.password
        params[:user] = config.username
        params[:password] = config.password
      end
      params[:headers] = headers
      RestClient::Request.execute(params) do |response, result, request, &block|
        if (200..207).include? response.code
          response.extend GithubReports::Response
        else
          response.return!(result, request, &block)
        end
      end
    end

    def self.headers
      {:accept => "application/vnd.github.v3+json"}
    end
  end
end
