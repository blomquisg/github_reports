require 'rest-client'
require 'yaml'
require 'singleton'
require_relative 'github_reports/api'

module GithubReports
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
