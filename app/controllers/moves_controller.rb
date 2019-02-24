class MovesController < ApplicationController
  def show
    @move = Storage::Move.find(params[:id])
    @game = @move.game

    @simulate_game = ::Game.from_json(@move.state)
    @move_decider = MoveDecider.new(@simulate_game)
    @simulated_move = @move_decider.next_move
  end
end
