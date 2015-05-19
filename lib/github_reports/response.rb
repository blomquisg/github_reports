require 'json'

module GithubReports
  module Response
    attr_reader :json

    def self.extended(response)
      raise ArgumentError.new("Invalid response type: #{response.class}") unless response.is_a? RestClient::Response
      response.init_json
      response
    end

    def items
      @json["items"] if @json
    end

    def total_count
      @json["total_count"] if @json
    end

    def incomplete_results
      @json["incomplete_results"] if @json
    end

    def page_links
      @pages_links ||= parse_page_links_header
    end

    def has_next_page?
      page_links.key? "next"
    end

    def next_page_url
      page_links["next"] if has_next_page?
    end

    def append(other_response)
      other_response.extend GithubReports::Response unless other_response.is_a? GithubReports::Response
      @json["items"] << other_response.items
      self.replace @json["items"]
    end

    def init_json
      @json = JSON.parse body
    end

    # taken from github-api gem
    # https://github.com/peter-murach/github/blob/caa69dd7868f67a88d6a9e699b64b63892255d7b/lib/github_api/page_links.rb#L16
    LINK_REGEX = /<([^>]+)>; rel=\"([^\"]+)\"/
    def parse_page_links_header
      page_links = {}
      if headers.key?(:link)
        links = headers[:link]
        links.split(",").each do |match|
          url, name = match[1], match[2]
          next unless url && name
          page_links[name] = url
        end
      end
      page_links
    end
  end
end
