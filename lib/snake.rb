class Point
  attr_reader :x, :y

  def initialize(data, y=nil)
    if y
      @x = data
      @y = y
    else
      @x = data['x']
      @y = data['y']
    end
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

  def hash
    [x, y].hash
  end

  def inspect
    "(#{x}, #{y})"
  end
end

class Snake
  attr_reader :id, :health, :body

  def initialize(data)
    @id = data['id']
    @health = data['health']
    @body = data['body'].map { |p| Point.new(p) }
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

  def length
    @body.length
  end

  def simulate!(action, game)
    board = game.board

    point = head.move(action)

    if board.out_of_bounds?(point)
      @health = 0
    elsif @body.include?(point)
      @health = 0
    end

    @body.unshift(point)

    self
  end
end

class Grid
  attr_reader :width, :height

  def initialize(width, height)
    @width = width
    @height = height
    @grid = Array.new(width * height)
  end

  def [](x, y=nil)
    unless y
      y = x.y
      x = x.x
    end
    return nil if x < 0 || y < 0 || x >= @width || y >= @height
    @grid[y * @width + x]
  end

  def []=(x, y, value=nil)
    unless value
      value = y
      y = x.y
      x = x.x
    end
    return if x < 0 || y < 0 || x >= @width || y >= @height
    @grid[y * @width + x] = value
  end
end

class Board
  attr_reader :snakes, :width, :height, :food

  def initialize(data)
    @width = data['width']
    @height = data['height']
    @snakes = data['snakes'].map { |s| Snake.new(s) }
    @food = data['food']
  end

  def initialize_copy(other)
    super(other)

    @snakes = @snakes.map(&:dup)
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

  def initialize(data)
    @id = data['game']['id']
    @turn = data['turn']
    @self_id = data['you']['id']
    @board = Board.new(data['board'])
  end

  def initialize_copy(other)
    super(other)
    @board = @board.dup
  end

  def player
    @board.snakes.detect { |s| s.id == @self_id }
  end

  def simulate(actions)
    game = dup
    game.simulate!(actions)
    game
  end

  def simulate!(actions)
    board.snakes.each do |snake|
      next unless snake.alive?
      action = actions[snake.id]
      next unless action

      snake.simulate!(action, self)
    end
  end
end

ACTIONS = [:up, :down, :left, :right]

class MoveDecider
  attr_reader :game
  def initialize(game)
    @game = game
  end

  def next_move
    self_id = @game.self_id

    ACTIONS.shuffle.detect do |action|
      game = @game.simulate({
        self_id => action
      })

      p(action => game.player)

      game.player.alive?
    end
  end
end

