require "test_helper"

class SimulationTest < MiniTest::Test
  def test_snakes_avoid_each_other
    snakes = [
      Snake.new(body: [Point.new(5,1), Point.new(4,1)]),
      Snake.new(body: [Point.new(6,1), Point.new(7,1)])
    ]
    board = Board.new(snakes: snakes, width: 10)
    game = Game.new(self_id: snakes[0].id, board: board)

    game.simulate!(
      snakes[0].id => :up,
      snakes[1].id => :down
    )

    assert_predicate snakes[0], :alive?
    assert_predicate snakes[1], :alive?
  end

  def test_snake_crashes_into_edge
    snakes = [
      Snake.new(body: [Point.new(5,0), Point.new(4,0)]),
      Snake.new(body: [Point.new(6,0), Point.new(7,0)])
    ]
    board = Board.new(snakes: snakes, width: 10)
    game = Game.new(self_id: snakes[0].id, board: board)

    game.simulate!(
      snakes[0].id => :up,
      snakes[1].id => :down
    )

    refute_predicate snakes[0], :alive?
    assert_predicate snakes[1], :alive?
  end

  def test_head_on_of_same_size
    snakes = [
      Snake.new(body: [Point.new(4,1), Point.new(3,1)]),
      Snake.new(body: [Point.new(6,1), Point.new(7,1)])
    ]
    board = Board.new(snakes: snakes, width: 10)
    game = Game.new(self_id: snakes[0].id, board: board)

    game.simulate!(
      snakes[0].id => :right,
      snakes[1].id => :left
    )

    refute_predicate snakes[0], :alive?
    refute_predicate snakes[1], :alive?
  end

  def test_head_on_of_different_size
    snakes = [
      Snake.new(body: [Point.new(4,1), Point.new(3,1)]),
      Snake.new(body: [Point.new(6,1), Point.new(7,1), Point.new(8,1)])
    ]
    board = Board.new(snakes: snakes, width: 10)
    game = Game.new(self_id: snakes[0].id, board: board)

    game.simulate!(
      snakes[0].id => :right,
      snakes[1].id => :left
    )

    refute_predicate snakes[0], :alive?
    assert_predicate snakes[1], :alive?
  end
end
