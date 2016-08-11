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
      if @current_bet
        "There is a pending build for commit **#{payload.commit_sha}** by **#{payload.sender_name}**, however another bet is already active, so betting on this won't be possible. Sorry!"
      else
        @bet_sha = payload.commit_sha
        @current_bet = {}

        chance_list = BetsFile.instance.chance_list(payload.sender_id)
        "There is a pending build for commit **#{payload.commit_sha}** by **#{payload.sender_name}**! Bets for success or failure are on!
**Statistics**: Committer **#{payload.sender_name}** (`#{payload.sender_id}`) has a build success chance of **#{(chance_list.last * 100).round(2)} %** (#{chance_list[0]} succeeded, #{chance_list[1]} failed).
Payout for success is **#{(1.0/chance_list[0]).round(2)}x**, for failure **#{(1.0/chance_list[1]).round(2)}x**.
Bet using the following format: `rubot, bet 10 on failure`"
      end
    when 'success'
    when 'failure'
    end
  end
end