require 'rest-client'
require 'yaml'
require 'singleton'
require_relative 'github_reports/api'
require_relative 'github_reports/runner'

module GithubReports
  def self.reports_dir
    # what should this be if it's not running in bundler?
    if defined? Bundler
      "reports/"
    else
      ""
    end
  end

  DEFAULT_CONFIG_FILE = '../config.yaml'

  class Config
    include Singleton
    attr_reader :host, :repo, :username, :password

    def initialize(config_file_path = DEFAULT_CONFIG_FILE)
      @config = YAML.load_file(File.join(__dir__, config_file_path))

      @repo = @config[:repo]
      @host = @config[:host]
      @username = @config[:username] if @config.key?(:username)
      @password = @config[:password] if @config.key?(:password)
    end
  end
end
