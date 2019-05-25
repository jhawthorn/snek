class Simulation
  attr_reader :turn, :width, :height, :board

  def initialize(scorer: nil)
    @turn = 0
    @width = @height = 11

    spawns = [
      Point.new(1,1),
      Point.new(width-2,height-2),
    ]

    snakes = spawns.map.with_index do |spawn, i|
      id = "snake#{i}"
      Snake.new(
        id: id,
        body: [spawn]*3
      )
    end

    food = 7.times.map do
      Point.new(rand(width), rand(height))
    end
    food.uniq!
    food -= spawns

    @board = Board.new(
      width: width,
      height: height,
      snakes: snakes,
      food: food
    )
  end

  def run(verbose: false)
    until over?
      if verbose
        puts "Turn #{@turn}:"
        puts @board.to_s
      end
      step
    end
    puts "winner is #{winner.name}" if verbose
    puts @board.to_s

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
    existing = @board.snakes.select(&:alive?).map(&:body).inject([], :+) + @board.food
    food = 3.times.map do
      Point.new(rand(width), rand(height))
    end

    food -= existing

    @board.food.concat food
  end

  def over?
    @board.snakes.count(&:alive?) <= 1
  end
end
