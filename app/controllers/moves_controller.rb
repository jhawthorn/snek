class MovesController < ApplicationController
  def show
    @move = Storage::Move.find(params[:id])
    @game = @move.game

    @simulate_game = ::Game.from_json(@move.state)
    scorer = ->(g) { MlScorer.new(g, weights: DefaultWeights) }
    @move_decider = MoveDecider.new(@simulate_game, scorer: scorer)
    @simulated_move = @move_decider.next_move
  end
end
