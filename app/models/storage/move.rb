class Storage::Move < ApplicationRecord
  serialize :state, JSON
  serialize :evaluations, JSON

  belongs_to :game

  validates :game_id, :turn, :snake_version, :decision, :state, :runtime, presence: true
end
