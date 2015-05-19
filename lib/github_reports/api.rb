require 'rest-client'
require_relative 'api/models'

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
    HOST = "https://api.github.com/"
    REPO = "ManageIQ/manageiq"

    def self.find_pull_requests(label = nil, state = "open")
      options = {"type" => "pr", "is" => state, "repo" => REPO}
      options["label"] = label if label
      response = search_issues(options)
      response.items.collect do |search_result|
        GithubReports::Models::PullRequest.new(search_result).
            init_pr(query(pull_request.pr_url)).
            init_comments(query(pull_request.comments_url)).
            init_review_comments(query(pull_request.review_comments_url))
      end
    end

    private

    # there are other options here, but only supporting these for now
    # https://developer.github.com/v3/search/#search-issues
    ISSUE_SEARCH_KEYS = %w(type is repo mentions label)
    def self.search_issues(options = {})
      uri = "#{HOST}/search/issues"
      query = []
      options.each.collect do |key, value|
        next unless ISSUE_SEARCH_KEYS.include? key
        "#{key}:#{value}"
      end.join("+")
      uri = "#{uri}?q=#{query}"
      response = query(uri)
    end

    def self.query(url)
      response = process_query(url)

      # bail on total count before trying to process any pages
      total_count = response.total_count
      raise TooManyResultsError.new(total_count, repsonse.request.url) if total_count > MAX_RESULTS

      # collect all pages
      combined_response = response
      while response.has_next_page?
        response = process_query(response.next_page)
        combined_response.append(response)
      end
      combined_response
    end

    def self.process_query(url)
      uri = add_results_per_page_param(uri, RESULTS_PER_PAGE)
      response = RestClient.get(url, {:accept => "application/vnd.github.v3+json"}) do |response, result, request, &block|
        if (200..207).include? response.code
          response.extend GithubReports::Response
        else
          response.return!(result, request, &block)
        end
      end
    end

    def self.add_results_per_page_param(uri, per_page)
      separator = uri.include?("?") ? "&" : "?"
      "#{uri}#{separator}per_page=#{per_page}"
    end
  end
end
