class MoveDecider
  attr_reader :game, :board

  def initialize(game, scorer: nil)
    @game = game
    @board = game.board

    @walls = board.new_grid
    @snakes = @game.snakes.select(&:alive?)
    @snakes.each do |snake|
      @walls.set_all(snake.body[0...-1], true)
    end

    @scorer_builder = scorer || ->(g){ GameScorer.new(g) }
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

  class Possibility
    attr_reader :initial_game, :moves, :game, :scorer

    def initialize(initial_game, moves, scorer:)
      @initial_game = initial_game
      @moves = moves
      @game = @initial_game.simulate(moves)
      @scorer = scorer.call(@game)
    end

    def score
      @score ||= @scorer.score
    end

    def moves_by_name
      snakes = @game.snakes.index_by(&:id)
      @moves.transform_keys { |key| snakes[key].name }
    end

    def player_move
      @moves[@game.player.id]
    end
  end

  def possible_futures(game: @game)
    all_move_combinations.map do |moves|
      Possibility.new(@game, moves, scorer: @scorer_builder)
    end
  end

  def move_scores
    # I don't know why the game server asks us this...
    return [[Snake::ACTIONS.sample, 0]] if @snakes.none?

    possibilities = possible_futures

    player_id = @game.player.id
    reasonable_moves[player_id].map do |action|
      relevant =
        possibilities.select do |possibility|
          possibility.player_move == action
        end

      possible_scores = relevant.map(&:score)
      [action, [possible_scores.min, possible_scores.sum/possible_scores.size]]
    end
  end

  def next_move
    move_scores.max_by(&:last).first
  end

  def all_move_combinations(possible_moves = reasonable_moves)
    if possible_moves.empty?
      return [{}]
    end

    snake_id = possible_moves.keys.first

    remaining_moves = possible_moves.dup
    my_moves = remaining_moves.delete(snake_id)

    other_combinations = all_move_combinations(remaining_moves)

    my_moves.flat_map do |my_move|
      other_combinations.map do |other_moves|
        { snake_id => my_move }.update(other_moves)
      end
    end
  end
end
