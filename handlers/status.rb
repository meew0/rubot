# frozen_string_literal: true

require 'json'
require 'singleton'

module RubotHandlers::Status
  class BetsFile
    include Singleton

    FILE_PATH = 'rubot-bets.json'

    attr_reader :balances
    attr_reader :chances

    def initialize
      read
    end

    def read
      obj = JSON.parse(File.read(FILE_PATH))

      @enabled_repos = obj['enabled_repos']
      @balances = obj['balances']
      @chances = obj['chances']
    end

    def write
      obj = {
        enabled_repos: @enabled_repos,
        balances: @balances,
        chances: @chances
      }

      File.write(FILE_PATH, obj.to_json)
    end

    def enabled?(repo)
      @enabled_repos.include? repo
    end
  end

  def self.handle(payload)
    case payload.state
    when 'pending'
    when 'success'
    when 'failure'
    end
  end
end