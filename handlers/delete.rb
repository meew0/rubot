# frozen_string_literal: true

module RubotHandlers::Delete
  def self.handle(payload)
    "deleted #{payload['ref_type']} **#{payload['ref']}**"
  end
end