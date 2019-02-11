require 'sinatra'
require 'json'
require "sinatra/json"

get '/' do
  'Battlesnake documentation can be found at' \
    '<a href=\"https://docs.battlesnake.io\">https://docs.battlesnake.io</a>.'
end

post '/start' do
  json(
    "color"=> "#fff000",
  )
end

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

    p board.height
    if point.x < 0 || point.y < 0 || point.x >= board.width || point.y >= board.height
      @health = 0
    elsif @body.include?(point)
      @health = 0
    end

    @body.unshift(point)

    self
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

post '/move' do
  requestBody = request.body.read
  requestJson = requestBody ? JSON.parse(requestBody) : {}

  original_game = Game.new(requestJson)
  self_id = original_game.self_id

  action =
    ACTIONS.shuffle.detect do |action|
      game = original_game.simulate({
        self_id => action
      })

      p(action => game.player)

      game.player.alive?
    end

  json(
    "move" => (action || :down)
  )
end

post '/end' do
  json({})
end

post '/ping' do
  200
end
