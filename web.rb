require "sinatra"
require "sinatra/json"
require "snake"

get '/' do
  'Battlesnake documentation can be found at' \
    '<a href=\"https://docs.battlesnake.io\">https://docs.battlesnake.io</a>.'
end

post '/start' do
  json(
    "color"=> "#fff000",
  )
end

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
