require 'sinatra'
require 'json'

post '/start' do
    requestBody = request.body.read
    requestJson = requestBody ? JSON.parse(requestBody) : {}

    # Dummy response
    responseObject = {
        "name" => "battlesnake-ruby",
        "color" => "cyan",
        "head_url" => "http://battlesnake-ruby.herokuapp.com/",
        "taunt" => "battlesnake-ruby"
    }

    return responseObject.to_json
end

post '/move' do
    requestBody = request.body.read
    requestJson = requestBody ? JSON.parse(requestBody) : {}

    # Dummy response
    responseObject = {
        "move" => "up",
        "taunt" => "going up!"
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
