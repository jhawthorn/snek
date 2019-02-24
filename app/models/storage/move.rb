class Storage::Move < ApplicationRecord
  serialize :state, JSON
  serialize :evaluations, JSON

  belongs_to :game

  validates :game_id, :turn, :snake_version, :decision, :state, :runtime, presence: true

  def heuristic_score
    game = ::Game.from_json(state)
    GameScorer.new(game).score
  end

  def remaining_snakes
    state['board']['snakes'].count
  end
end
