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

    def chance_list(id)
      unless @chances[id]
        @chances[id] = [0, 0]
        return [0, 0, 0]
      end

      list = @chances[id]
      if list[0] == list[1] == 0
        list << 0
      else
        list << (list[0].to_f / (list[0] + list[1]))
      end

      list
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