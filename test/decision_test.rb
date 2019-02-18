require "test_helper"

class DecisionTest < MiniTest::Test
  def test_avoids_head_on
    snakes = [
      Snake.new(body: [Point.new(5,1), Point.new(4,1), Point.new(3,1)]),
      Snake.new(body: [Point.new(6,1), Point.new(7,1), Point.new(7,1)])
    ]
    board = Board.new(snakes: snakes)
    game = Game.new(board: board, self_id: snakes[0].id)
    move =  MoveDecider.new(game).next_move

    assert_includes [:up, :down], move
  end

  def test_makes_easy_kill
    snakes = [
      Snake.new(body: [Point.new(3,1), Point.new(2,1), Point.new(1,1), Point.new(1,0)]),
      Snake.new(body: [Point.new(2,0), Point.new(1,0), Point.new(0,0)])
    ]
    board = Board.new(snakes: snakes)
    game = Game.new(board: board, self_id: snakes[0].id)
    move =  MoveDecider.new(game).next_move

    assert_equal :up, move
  end

  def test_doesnt_give_up
    snakes = [
      Snake.new(body: [Point.new(2,0), Point.new(1,0), Point.new(0,0)]),
      Snake.new(body: [Point.new(3,1), Point.new(2,1), Point.new(1,1), Point.new(0,1)])
    ]
    board = Board.new(snakes: snakes)
    game = Game.new(board: board, self_id: snakes[0].id)
    move =  MoveDecider.new(game).next_move

    assert_equal :right, move
  end
end
