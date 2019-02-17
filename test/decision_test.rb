require "test_helper"

class DecisionTest < MiniTest::Test
  def test_avoids_head_on
    snakes = [
      Snake.new(body: [Point.new(5,1), Point.new(4,1)]),
      Snake.new(body: [Point.new(6,1), Point.new(7,1)])
    ]
    board = Board.new(snakes: snakes)
    game = Game.new(board: board, self_id: snakes[0].id)

    move =  MoveDecider.new(game).next_move

    assert_includes [:up, :down], move
  end
end
