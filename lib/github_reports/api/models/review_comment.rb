module GithubReports
  class ReviewComment < Comment

    def initialize(review_comment_results)
      super
      @position = review_comment_results["position"]
    end

    def open?
      !!@position
    end
  end
end
