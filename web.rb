require "sinatra"
require "sinatra/json"

$LOAD_PATH.unshift "#{__dir__}/lib"
require "snake"

COLOUR = "#24292e"
HEAD_TYPE = "silly"
TAIL_TYPE = "block-bum"

get '/' do
  'Battlesnake documentation can be found at' \
    '<a href=\"https://docs.battlesnake.io\">https://docs.battlesnake.io</a>.'
end

post '/start' do
  json(color: COLOUR, headType: HEAD_TYPE, tailType: TAIL_TYPE)
end

post '/move' do
  requestBody = request.body.read
  logger.info requestBody
  requestJson = requestBody ? JSON.parse(requestBody) : {}

  game = Game.from_json(requestJson)
  move = MoveDecider.new(game).next_move

  json(move: move || :down)
end

post '/end' do
  json({})
end

post '/ping' do
  200
end
