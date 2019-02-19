
require "test_helper"

class DecisionTest < MiniTest::Test
  def test_cornered
    snake = Snake.new(body: [Point.new(6,4), Point.new(6,3), Point.new(7,3), Point.new(7,4), Point.new(7,5), Point.new(6,5), Point.new(5,5), Point.new(5,4), Point.new(5,3)])
    board = Board.new(snakes: [snake])
    game = Game.new(board: board, self_id: snake.id)

    scorer = GameScorer.new(game)

    # Score should be awful. We are dead next turn
    assert scorer.score < -999999
  end
end
