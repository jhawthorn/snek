class Simulation
  attr_reader :turn, :width, :height, :board

  INITIAL_FOOD = 6
  DEFAULT_SIZE = 11

  def initialize(size: DEFAULT_SIZE, snake_count: 2, scorer: nil)
    @turn = 0
    @width = @height = size
    @scorer = scorer

    possible_spawns = [
      Point.new(1, 1),
      Point.new(width/2, 1),
      Point.new(width-2, 1),

      Point.new(1,height/2),
      Point.new(width-2,height/2),

      Point.new(1, height-2),
      Point.new(width/2, height-2),
      Point.new(width-2, height-2),
    ]

    spawns = possible_spawns.sample(snake_count)

    snakes = spawns.map.with_index do |spawn, i|
      id = "snake#{i}"
      Snake.new(
        id: id,
        body: [spawn]*3
      )
    end

    @board = Board.new(
      width: width,
      height: height,
      snakes: snakes,
      food: []
    )

    (INITIAL_FOOD / 2).times do
      spawn_food!
    end
  end

  def run(verbose: false)
    until over?
      if verbose
        puts "Turn #{@turn}:"
        puts @board.to_s
      end
      step
    end
    if verbose
      if winner
        puts "winner is #{winner.name}"
      else
        puts "tie?"
      end
    end

    winner
  end

  def winner
    @winner ||=
      begin
        raise "it's not over yet" unless over?

        @board.snakes.detect(&:alive?)
      end
  end

  def step
    snakes = @board.snakes.select(&:alive?)

    actions = Hash[
      snakes.map do |snake|
        game = Game.new(
          self_id: snake.id,
          turn: @turn,
          board: @board.dup
        )

        move = MoveDecider.new(game, scorer: @scorer).next_move

        [snake.id, move]
      end
    ]

    @board.simulate!(actions)

    @turn += 1
    spawn_food! if turn > 0 && (turn % 10) == 0
  end

  def spawn_food!
    existing = @board.snakes.select(&:alive?).map(&:body).inject([], :+) + @board.food.to_a
    x = rand(width)
    y = rand(height)

    food = [
      Point.new(x, y),
      Point.new(width - x - 1, height - y - 1),
    ]

    food.uniq!
    food -= @board.snakes.flat_map(&:body)
    food -= existing

    @board.food.merge food
  end

  def over?
    @board.snakes.count(&:alive?) <= 1
  end
end
