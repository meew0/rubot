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
      id = id.to_s

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

    def update_chance(id, state)
      id = id.to_s

      @chances[id] ||= [0, 0]
      @chances[id][state] += 1

      @chances[id]
    end

    def update_balance(id, delta)
      id = id.to_s

      @balances[id] += delta
      @balances[id]
    end
  end

  PARTICIPLES = {
    'success' => 'succeeded',
    'failure' => 'failed'
  }.freeze

  STATE_NUMS = {
    'success' => 0,
    'failure' => 1
  }.freeze

  GEM = '💎'.freeze

  def self.format_chance_list(chance_list)
    "**#{(chance_list.last * 100).round(2)} %** (#{chance_list[0]} succeeded, #{chance_list[1]} failed)"
  end

  def self.conclude_bet(payload)
    if payload.commit_sha == @bet_sha
      participle = PARTICIPLES[payload.state]
      state = STATE_NUMS[payload.state]

      new_chances = BetsFile.update_chance(payload.sender_id, state)

      str = "The build for commit **#{payload.commit_sha}** has **#{participle}**!
Chances for committer #{payload.sender_name} have been updated to #{format_chance_list(new_chances)}."

      @current_bet.each do |better|
        # [id, name, amount, state_num]
        delta = better[2] * @payouts[better[3]]

        BetsFile.update_balance(better[0], delta)
        str += "**#{better[1]}** has #{delta >= 0 ? 'won' : 'lost'} **#{delta.abs} #{GEM}**."
      end

      BetsFile.write
      str
    else
      puts 'Note: conclude_bet called for commit not equal to current bet. Ignoring'
      ''
    end
  end

  def self.bet(id, name, amount, state_num)
    return false unless @current_bet

    @current_bet << [id, name, amount, state_num]
    true
  end

  def self.handle(payload)
    case payload.state
    when 'pending'
      if @current_bet
        "There is a pending build for commit **#{payload.commit_sha}** by **#{payload.sender_name}**, however another bet is already active, so betting on this won't be possible. Sorry!"
      else
        @bet_sha = payload.commit_sha
        @current_bet = []
        @payouts = chance_list[0..1].map { |e| (1.0/e).round(2) }

        chance_list = BetsFile.instance.chance_list(payload.sender_id)
        "There is a pending build for commit **#{payload.commit_sha}** by **#{payload.sender_name}**! Bets for success or failure are on!
**Statistics**: Committer **#{payload.sender_name}** (`#{payload.sender_id}`) has a build success chance of #{format_chance_list(chance_list)}.
Payout for success is **#{@payouts[0]}x**, for failure **#{@payouts[1]}x**.
Bet using the following format: `rubot, bet 10 on failure`"
      end
    when 'success'
      conclude_bet(payload)
    when 'failure'
      conclude_bet(payload)
    end
  end
end