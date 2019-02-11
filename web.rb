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

class Snake
  def initialize(data)
    @id = data['id']
    @health = data['health']
    @body = data['body']
  end
end

class Board
  def initialize(data)
    @width = data['width']
    @height = data['height']
    @snakes = data['snakes'].map { |s| Snake.new(s) }
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
end

post '/move' do
  requestBody = request.body.read
  requestJson = requestBody ? JSON.parse(requestBody) : {}

  game = Game.new(requestJson)
  p game.dup

  # Calculate a direction (example)
  direction = ["up", "right"].sample

  json(
    "move" => direction
  )
end

post '/end' do
  json({})
end

post '/ping' do
  200
end
