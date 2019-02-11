require 'sinatra'
require 'json'

get '/' do
  'Battlesnake documentation can be found at' \
    '<a href=\"https://docs.battlesnake.io\">https://docs.battlesnake.io</a>.'
end

post '/start' do
  requestBody = request.body.read
  requestJson = requestBody ? JSON.parse(requestBody) : {}

  # Example response
  responseObject = {
    "color"=> "#fff000",
  }

  return responseObject.to_json
end

post '/move' do
  requestBody = request.body.read
  requestJson = requestBody ? JSON.parse(requestBody) : {}

  # Calculate a direction (example)
  direction = ["up", "right"].sample

  # Example response
  responseObject = {
    "move" => direction
  }

  return responseObject.to_json
end

post '/end' do
  requestBody = request.body.read
  requestJson = requestBody ? JSON.parse(requestBody) : {}

  # No response required
  responseObject = {}

  return responseObject.to_json
end

post '/ping' do
  200
end
