class MoveDecider
  attr_reader :game, :board

  def initialize(game)
    @game = game
    @board = game.board

    @walls = board.new_grid
    @snakes = @game.snakes.select(&:alive?)
    @snakes.each do |snake|
      @walls.set_all(snake.body[0...-1], true)
    end
  end

  def considered_snakes
    return @snakes if @snakes.count <= 4

    player = @game.player

    @snakes.sort_by do |snake|
      (snake.head.x - player.head.x).abs + (snake.head.y - player.head.y).abs
    end.first(4)
  end

  def reasonable_moves
    @reasonable_moves ||=
      Hash[
        considered_snakes.map do |snake|
          moves = Snake::ACTIONS.reject do |move|
            head = snake.head
            new_head = head.move(move)

            board.out_of_bounds?(new_head) || @walls.get(new_head)
          end

          moves << Snake::ACTIONS.sample if moves.empty?

          [snake.id, moves]
        end
      ]
  end

  def move_scores
    # I don't know why the game server asks us this...
    return [[Snake::ACTIONS.sample, 0]] if @snakes.none?

    possibilities = all_move_combinations.to_a

    possibilities.map! do |moves|
      game = @game.simulate(moves)

      score = GameScorer.new(game).score

      [moves, score]
    end

    player_id = @game.player.id
    reasonable_moves[player_id].map do |action|
      relevant =
        possibilities.select do |(possibility, _)|
          possibility[player_id] == action
        end

      [action, relevant.map(&:last).min]
    end
  end

  def next_move
    move_scores.max_by(&:last).first
  end

  def all_move_combinations(possible_moves = reasonable_moves)
    return enum_for(__method__, possible_moves) unless block_given?

    if possible_moves.empty?
      return yield({})
    end

    snake_id = possible_moves.keys.first

    remaining_moves = possible_moves.dup
    my_moves = remaining_moves.delete(snake_id)

    my_moves.each do |my_move|
      all_move_combinations(remaining_moves) do |other_moves|
        yield({ snake_id => my_move }.merge(other_moves))
      end
    end
  end
end
