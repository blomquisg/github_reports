module GithubReports
  class Comment
    attr_reader :body, :user, :url, :created_at

    def initialize(comment_results)
      @body       = comment_results["body"]
      @url        = comment_results["url"]
      @user       = comment_results["user"]["login"]
      @created_at = comment_results["created_at"]
    end
  end
end
