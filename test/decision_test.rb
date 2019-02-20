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

  def test_will_eat
    snake = Snake.new(body: [Point.new(5,5), Point.new(5,4), Point.new(5,3)])
    board = Board.new(snakes: [snake], food: [Point.new(5,6)])
    game = Game.new(board: board, self_id: snake.id)

    move =  MoveDecider.new(game).next_move

    assert_equal :down, move
  end

  def test_still_take_action_if_opponent_screwed
    snakes = [
      Snake.new(body: [Point.new(5,5), Point.new(5,6), Point.new(5,7)]),
      Snake.new(body: [Point.new(0,0), Point.new(0,1), Point.new(1,1), Point.new(1,0), Point.new(2,0)])
    ]
    board = Board.new(snakes: snakes, food: [Point.new(5,6)])

    game = Game.new(board: board, self_id: snakes[0].id)

    move =  MoveDecider.new(game).next_move

    assert_includes ACTIONS, move
  end

  def test_will_eat_mostly_surrounded
    snake = Snake.new(body: [Point.new(7,4), Point.new(7,5), Point.new(6,5), Point.new(5,5), Point.new(5,4), Point.new(5,3)])
    board = Board.new(snakes: [snake], food: [Point.new(6,4)])
    game = Game.new(board: board, self_id: snake.id)

    move =  MoveDecider.new(game).next_move

    assert_equal :left, move
  end

  def test_wont_eat_fully_surrounded
    snake = Snake.new(body: [Point.new(6,3), Point.new(7,3), Point.new(7,4), Point.new(7,5), Point.new(6,5), Point.new(5,5), Point.new(5,4), Point.new(5,3)])
    board = Board.new(snakes: [snake], food: [Point.new(6,4)])
    game = Game.new(board: board, self_id: snake.id)

    move =  MoveDecider.new(game).next_move

    refute_equal :down, move
  end

  def test_wont_eat_doomed
    snake = Snake.new(body: [Point.new(6,3), Point.new(7,3), Point.new(7,4), Point.new(7,5), Point.new(7,6), Point.new(6,6), Point.new(5,6), Point.new(5,5), Point.new(5,4), Point.new(5,3)])
    board = Board.new(snakes: [snake], food: [Point.new(6,4)])
    game = Game.new(board: board, self_id: snake.id)

    move =  MoveDecider.new(game).next_move

    refute_equal :down, move
  end

  def test_wont_eat_also_doomed
    snake = Snake.new(body: [Point.new(6,2), Point.new(7,2), Point.new(7,3), Point.new(7,4), Point.new(7,5), Point.new(7,6), Point.new(6,6), Point.new(5,6), Point.new(5,5), Point.new(5,4), Point.new(5,3)])
    board = Board.new(snakes: [snake], food: [Point.new(6,4)])
    game = Game.new(board: board, self_id: snake.id)

    move =  MoveDecider.new(game).next_move

    refute_equal :down, move
  end
end
