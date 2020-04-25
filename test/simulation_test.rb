require "test_helper"

class SimulationTest < MiniTest::Test
  def test_snakes_avoid_each_other
    snakes = [
      Snake.new(body: [Point.new(5,1), Point.new(4,1)]),
      Snake.new(body: [Point.new(6,1), Point.new(7,1)])
    ]
    board = Board.new(snakes: snakes)

    board.simulate!(
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
    board = Board.new(snakes: snakes)

    board.simulate!(
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
    board = Board.new(snakes: snakes)

    board.simulate!(
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
    board = Board.new(snakes: snakes)

    board.simulate!(
      snakes[0].id => :right,
      snakes[1].id => :left
    )

    refute_predicate snakes[0], :alive?
    assert_predicate snakes[1], :alive?
  end

  def test_can_move_into_own_tain
    snake = Snake.new(body: [Point.new(4,1), Point.new(3,1), Point.new(3,2), Point.new(4,2)])
    board = Board.new(snakes: [snake])

    board.simulate!(snake.id => :down)

    assert_predicate snake, :alive?
    assert_equal [Point.new(4,2), Point.new(4,1), Point.new(3,1), Point.new(3,2)], snake.body
  end

  # Apparently this will be the new rule
  def test_cant_move_into_own_tain_if_just_grown
    snake = Snake.new(body: [Point.new(4,1), Point.new(3,1), Point.new(3,2), Point.new(4,2), Point.new(4,2)])
    board = Board.new(snakes: [snake])

    board.simulate!(snake.id => :down)

    refute_predicate snake, :alive?
  end

  def test_eats_food
    snake = Snake.new(body: [Point.new(4,1), Point.new(3,1), Point.new(2,1)])
    board = Board.new(snakes: [snake], food: [Point.new(4,2)])

    board.simulate!(snake.id => :down)

    assert_predicate snake, :alive?
    assert_equal [Point.new(4,2), Point.new(4,1), Point.new(3,1), Point.new(3,1)], snake.body
    assert_equal Set.new, board.food
  end

  def test_crash_into_food
    snakes = [
      Snake.new(body: [Point.new(4,1), Point.new(3,1)]),
      Snake.new(body: [Point.new(6,1), Point.new(7,1)])
    ]
    board = Board.new(snakes: snakes, food: [Point.new(5,1)])

    board.simulate!(
      snakes[0].id => :right,
      snakes[1].id => :left
    )

    refute_predicate snakes[0], :alive?
    refute_predicate snakes[1], :alive?
  end

  def test_simulation_works
    simulation = Simulation.new
    refute simulation.over?
    assert_equal 2, simulation.board.snakes.count

    simulation.run

    assert simulation.over?
    assert simulation.winner
  end
end
