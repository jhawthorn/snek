# frozen_string_literal: true

class Storage::Move < ApplicationRecord
  serialize :state, JSON
  serialize :evaluations, JSON

  belongs_to :game

  validates :game_id, :turn, :snake_version, :decision, :state, :runtime, presence: true

  def heuristic_score
    @score ||= GameScorer.new(simulated_game).score
  end

  def move_decider
    @move_decider ||= MoveDecider.new(simulated_game)
  end

  def remaining_snakes
    state['board']['snakes'].count
  end

  def before_image_url
    game.turn_image_url(turn)
  end

  def after_image_url
    game.turn_image_url(turn+1)
  end

  def prev
    game.moves.find_by(turn: turn-1)
  end

  def next
    game.moves.find_by(turn: turn+1)
  end

  def simulated_game
    @game ||= ::Game.from_json(state)
  end

  def remote_latency
    my_id = state["you"]["id"]
    frame = game.frame_data.detect { |x| x["Turn"] == turn + 1 }
    my_snake = frame && frame["Snakes"].detect { |x| x["ID"] == my_id }
    latency = (my_snake && my_snake["Latency"]).to_i
  end
end
