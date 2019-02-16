require "securerandom"

unless [].respond_to?(:sum)
  class Array
    def sum(&block)
      if block_given?
        map(&block).inject(0, :+)
      else
        inject(0, :+)
      end
    end
  end
end

ACTIONS = [:up, :down, :left, :right]

SCORE_MIN = -999999999
SCORE_MAX =  999999999

class Point
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def self.from_json(data)
    new(
      data['x'],
      data['y']
    )
  end

  def move(direction)
    case direction
    when :up
      Point.new(x, y-1)
    when :down
      Point.new(x, y+1)
    when :left
      Point.new(x-1, y)
    when :right
      Point.new(x+1, y)
    end
  end

  def ==(other)
    x == other.x && y == other.y
  end

  def eql?(other)
    x == other.x && y == other.y
  end

  def hash
    [x, y].hash
  end

  def inspect
    "(#{x}, #{y})"
  end
end

class Snake
  attr_reader :id, :health, :body
  attr_writer :health

  def initialize(id: nil, health: 100, body: [])
    @id = id || SecureRandom.hex
    @health = health
    @body = body
  end

  def self.from_json(data)
    new(
      id: data['id'],
      health: data['health'],
      body: data['body'].map { |p| Point.from_json(p) }
    )
  end

  def initialize_copy(other)
    super(other)

    @body = @body.dup
  end

  def alive?
    health > 0
  end

  def head
    @body[0]
  end

  def tail
    @body.drop_while { |x| x == head }
  end

  def length
    @body.length
  end

  def die!
    @health = 0
  end

  def simulate!(action, game)
    point = head.move(action)

    @body.unshift(point)

    self
  end

  def hash
    @id.hash
  end

  def ==(other)
    id == other.id
  end
end

class Grid
  attr_reader :width, :height

  def initialize(width, height)
    @width = width
    @height = height
    @grid = Array.new(width * height)
  end

  def get(x, y=nil)
    unless y
      y = x.y
      x = x.x
    end
    raise if x < 0 || y < 0 || x >= @width || y >= @height
    @grid[y * @width + x]
  end

  def at(x, y)
    @grid[y * @width + x]
  end

  def set(x, y, value=nil)
    unless value
      value = y
      y = x.y
      x = x.x
    end
    raise if x < 0 || y < 0 || x >= @width || y >= @height
    @grid[y * @width + x] = value
  end

  def set_all(points, value)
    points.each do |point|
      self.set(point, value)
    end
  end

  def inspect
    values = @grid.map(&:inspect)
    hsize = values.map(&:size).max + 1
    values.map! { |v| v.ljust(hsize) }
    "#<Grid #{@width}x#{@height}\n" + values.each_slice(@width).map(&:join).join("\n") + "\n>"
  end
end

class Board
  attr_reader :snakes, :width, :height, :food

  def initialize(width:, height: width, snakes: [], food: [])
    @width = width
    @height = height
    @snakes = snakes
    @food = food
  end

  def self.from_json(data)
    new(
      width: data['width'],
      height: data['height'],
      snakes: data['snakes'].map { |s| Snake.from_json(s) },
      food: data['food'].map { |f| Point.from_json(f) }
    )
  end

  def initialize_copy(other)
    super(other)

    @snakes = @snakes.map(&:dup)
    @food = @food.map(&:dup)
  end

  def new_grid
    Grid.new(@width, @height)
  end

  def out_of_bounds?(x, y=nil)
    unless y
      y = x.y
      x = x.x
    end
    x < 0 || y < 0 || x >= @width || y >= @height
  end
end

class Game
  attr_reader :id, :turn, :self_id, :board

  def initialize(id: nil, turn: 0, self_id:, board:)
    @id = id || SecureRandom.hex
    @turn = turn
    @self_id = self_id
    @board = board
  end

  def self.from_json(data)
    new(
      id: data['game']['id'],
      turn: data['turn'],
      self_id: data['you']['id'],
      board: Board.from_json(data['board'])
    )
  end

  def initialize_copy(other)
    super(other)
    @board = @board.dup
  end

  def snakes
    @board.snakes
  end

  def player
    snakes.detect { |s| s.id == @self_id }
  end

  def enemies
    snakes - [player]
  end

  def simulate(actions)
    game = dup
    game.simulate!(actions)
    game
  end

  def simulate!(actions)
    snakes = board.snakes.select(&:alive?)

    snakes.each do |snake|
      action = actions[snake.id]
      next unless action

      snake.simulate!(action, self)
    end

    snakes.each do |snake|
      snake.health -= 1
    end

    eaten_food = []
    snakes.each do |snake|
      if board.food.include?(snake.head)
        eaten_food << snake.head
      elsif actions[snake.id]
        snake.body.pop
      else
        # We didn't simulate a move
      end
    end
    eaten_food.each do |food|
      board.food.delete(food)
    end

    heads = snakes.group_by(&:head)
    walls = Grid.new(board.width, board.height)
    snakes.each do |snake|
      walls.set_all(snake.tail, true)
    end

    snakes.each do |snake|
      if board.out_of_bounds?(snake.head)
        snake.die!
        next
      end

      if walls.get(snake.head)
        snake.die!
        next
      end

      lost_collision =
        heads[snake.head].any? do |other|
          next if other.equal?(snake)

          other.length >= snake.length
        end

      if lost_collision
        snake.die!
        next
      end
    end
  end
end

class BoardBFS
  attr_reader :game, :board

  attr_reader :voronoi_tiles
  attr_reader :distance_to_food

  def initialize(game)
    @game = game
    @board = game.board
    @snakes = board.snakes.select(&:alive?)

    @voronoi_tiles = Hash.new(0).compare_by_identity
    @distance_to_food = {}.compare_by_identity

    calculate
  end

  def calculate
    visited = Grid.new(board.width, board.height)
    food = Grid.new(board.width, board.height)

    width_1 = @board.width - 1
    height_1 = @board.height - 1

    next_queue = []

    food.set_all(board.food, true)

    snakes = @snakes.sort_by do |snake|
      -snake.length
    end

    snakes.each do |snake|
      unless board.out_of_bounds?(snake.head)
        next_queue << [snake.head.x, snake.head.y, snake]
      end

      snake.tail.each do |point|
        visited.set(point, true)
      end
    end

    distance = 0
    until next_queue.empty?
      queue = next_queue
      next_queue = []

      queue.each do |x, y, snake|
        next if visited.at(x,y)
        visited.set(x, y, true)

        @voronoi_tiles[snake] += 1

        if food.at(x,y)
          @distance_to_food[snake] ||= distance
        end

        next_queue << [x+1, y, snake] if x < width_1
        next_queue << [x-1, y, snake] if x > 0
        next_queue << [x, y+1, snake] if y < height_1
        next_queue << [x, y-1, snake] if y > 0
      end

      snakes.reverse_each do |snake|
        break if snake.length < distance
        next if snake.length < distance-1 && snake.body[-distance] == snake.body[-distance-1]

        visited.set(snake.body[-distance], false)
      end

      distance += 1
    end
  end
end

class GameScorer
  def initialize(game, bfs: nil)
    @game = game
    @bfs = bfs || BoardBFS.new(@game)
  end

  def score
    player = @game.player
    return SCORE_MIN unless player.alive?

    # If there was at least one enemy, but now is dead, victory
    # Necessary so we still somewhat play a single player game
    if @game.enemies.any? && @game.enemies.none?(&:alive?)
      return SCORE_MAX
    end

    # If we're 100% backed into a corner
    # This basically saves us one turn of simulation
    if @bfs.voronoi_tiles[player] == 0
      return SCORE_MIN + 10
    end

    distance_to_food = @bfs.distance_to_food[player] || @game.board.width * 2
    if distance_to_food > 10
      distance_to_food /= 100.0
      distance_to_food += 10
    end

    # Make it urgent if we are near death
    distance_to_food *= 10 if player.health < 20

    enemies = @game.enemies.select(&:alive?)

    [
        50 * player.length,
         1 * player.health,
      -250 * enemies.count,
        -1 * (enemies.map(&:length).max || 0),
        -1 * enemies.sum(&:length),

         1 * @bfs.voronoi_tiles[player],
        -1 * distance_to_food
    ].sum
  end
end

class MoveDecider
  attr_reader :game, :board

  def initialize(game)
    @game = game
    @board = game.board

    @walls = board.new_grid
    @snakes = @game.snakes.select(&:alive?)
    @snakes.each do |snake|
      @walls.set_all(snake.body, true)
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
          moves = ACTIONS.reject do |move|
            head = snake.head
            new_head = head.move(move)

            board.out_of_bounds?(new_head) || @walls.get(new_head)
          end

          [snake.id, moves]
        end
      ]
  end

  def next_move
    # I don't know why the game server asks us this...
    return ACTIONS.sample if @snakes.none?

    possibilities = all_move_combinations.to_a

    possibilities.map! do |moves|
      game = @game.simulate(moves)

      score = GameScorer.new(game).score

      [moves, score]
    end

    player_id = @game.player.id
    reasonable_moves[player_id].max_by do |action|
      relevant =
        possibilities.select do |(possibility, _)|
          possibility[player_id] == action
        end

      relevant.map(&:last).min
    end
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

