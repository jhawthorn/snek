require "test_helper"

class DecisionTest < ActiveSupport::TestCase
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

  def test_will_eat_on_large_board
    snake = Snake.new(body: [Point.new(5,5), Point.new(5,4), Point.new(5,3)])
    board = Board.new(snakes: [snake], food: [Point.new(5,6)], width: 17)
    game = Game.new(board: board, self_id: snake.id)

    move =  MoveDecider.new(game).next_move

    assert_equal :down, move
  end

  def test_will_eat_on_large_board_with_food_in_corner
    snake = Snake.new(body: [Point.new(0,5), Point.new(0,4), Point.new(0,3)])
    board = Board.new(snakes: [snake], food: [Point.new(0,6), Point.new(16,16)], width: 17)
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

    assert_includes Snake::ACTIONS, move
  end

  def test_will_eat_mostly_surrounded
    snake = Snake.new(body: [Point.new(7,4), Point.new(7,5), Point.new(6,5), Point.new(5,5), Point.new(5,4), Point.new(5,3)])
    board = Board.new(snakes: [snake], food: [Point.new(6,4)])
    game = Game.new(board: board, self_id: snake.id)

    move =  MoveDecider.new(game).next_move

    assert_equal :left, move
  end

  def test_will_eat_with_stuff_going_on
    game = game_fixture("input-a8500ec3-f10a-4eab-9bc0-9df1f2b95cfb-turn-178.json")

    move = MoveDecider.new(game).next_move

    assert_equal :down, move
  end

  def test_will_eat_first_turn
    game = game_fixture("input-54e3457f-b4c9-4cf1-8491-92784fa605ae-turn-0.json")

    move = MoveDecider.new(game).next_move

    assert_equal :right, move
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

  def test_doesnt_dead_end
    game = game_fixture("input-5173cabc-56f4-43c2-8eb3-07416f4bc49f-turn-355.json")
    move =  MoveDecider.new(game).next_move
    assert_equal :down, move
  end

  def test_battlesnake_2020_stay_home_and_code_loss
    game = game_fixture("input-2da76c63-49db-481b-8e71-8d5349f4a451-turn-395.json")
    decider = MoveDecider.new(game)
    move = decider.next_move
    assert_equal :right, move
  end
end
