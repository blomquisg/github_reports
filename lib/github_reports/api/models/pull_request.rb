require_relative 'comment'
require_relative 'review_comment'

module GithubReports
  class PullRequest

    attr_reader :number,
                :title,
                :description,
                :state,
                :submitter,
                :mergeable_state,
                :merged_by,
                :milestone,
                :labels,
                :comments,
                :review_comments,
                :issue_url,
                :pr_url,
                :comments_url,
                :review_comments_url

    def initialize(search_results)
      @number      = search_results["number"]
      @title       = search_results["title"]
      @description = search_results["body"]
      @state       = search_results["state"]

      @submitter = parse_submitter(search_results["user"])
      @labels    = parse_labels(search_results["labels"])

      @issue_url    = search_results["url"]
      @pr_url       = search_results["pull_request"]["url"]
      @comments_url = search_results["comments_url"]
      yield self if block_given?
    end

    def init_pr(pr_results)
      @mergeable           = pr_results["mergeable"]
      @mergeable_state     = pr_results["mergeable_state"]
      @review_comments_url = pr_results["review_comments_url"]
      self
    end

    def init_comments(comments_results)
      @comments = comments_results.collect do |comment_results|
        Comment.new(comment_results)
      end
      self
    end

    def init_review_comments(review_comments_results)
      @review_comments = review_comments_results.collect do |review_comment_results|
        ReviewComment.new(review_comment_results)
      end
      self
    end

    def open_review_comments_count
      review_comments.select(&:open?).size
    end

    def mergeable?
      !!@mergeable
    end
    private

    def parse_submitter(submitter_hash)
      submitter_hash["login"]
    end

    def parse_labels(labels_hash)
      labels_hash.collect {|label| label["name"] }
    end

    def init_from_search(data)
      @number     = data.number
      @title      = data.title
      @desciption = data.body
      @state      = data.state
      @submitter  = data.user.login
    end

    def init_from_pr(data)
      @mergeable = data.mergeable
      @mergeable_state = data.mergeable_state
      @additions = data.additions
      @deletions = data.deletions
    end

    def init_from_issue(data)
      @labels = data.labels.collect {|label| label.name } if data.labels
    end
  end
end
