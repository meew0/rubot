# frozen_string_literal: true

module RubotHandlers::Fork
  def self.handle(payload)
    "forked this repo to **#{payload['forkee']['full_name']}**."
  end
end