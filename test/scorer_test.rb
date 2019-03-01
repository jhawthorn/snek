
require "test_helper"

class ScorerTest < ActiveSupport::TestCase
  def test_cornered
    snake = Snake.new(body: [Point.new(6,4), Point.new(6,3), Point.new(7,3), Point.new(7,4), Point.new(7,5), Point.new(6,5), Point.new(5,5), Point.new(5,4), Point.new(5,3)])
    board = Board.new(snakes: [snake])
    game = Game.new(board: board, self_id: snake.id)

    scorer = GameScorer.new(game)

    # Score should be awful. We are dead next turn
    assert scorer.score < -999999
  end

  def test_eating_food
    game = game_fixture("input-a8500ec3-f10a-4eab-9bc0-9df1f2b95cfb-turn-178.json")
    before = GameScorer.new(game).score

    game.simulate!({ game.player.id => :down, game.enemies[0].id => :up })

    after = GameScorer.new(game).score

    assert before < after
  end
end
