class Simulation
  attr_reader :turn, :width, :height, :board

  INITIAL_FOOD = 6
  DEFAULT_SIZE = 11

  def initialize(size: DEFAULT_SIZE, snake_count: 2, scorer: nil)
    @turn = 0
    @width = @height = size
    @scorer = scorer

    # hazards
    @minx = @miny = 0
    @maxx = @maxy = size - 1

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

    food_spawn_chance = 15

    if rand(100) < food_spawn_chance || @board.food.empty?
      spawn_food!
    end

    hazard_turns = 20
    if (@turn % hazard_turns) == 0 && @turn > 0
      shrink_hazard!
    end
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

  def shrink_hazard!
    case rand(4)
    when 0
      @minx += 1
    when 1
      @maxx -= 1
    when 2
      @miny += 1
    when 3
      @maxy -= 1
    end

    0.upto(height) do |y|
      0.upto(width) do |x|
        if x < @minx || x > @maxx || y < @miny || y > @maxy
          @board.hazards.add(Point.new(x,y))
        end
      end
    end
  end

  def over?
    @board.snakes.count(&:alive?) <= 1
  end
end
