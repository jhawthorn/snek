require 'sinatra'
require 'json'

post '/start' do
    requestBody = request.body.read

    if requestBody
        requestJson = JSON.parse(requestBody)
    else
        requestJson = {}
    end

    # Dummy response
    response = {
        "name" => "battlesnake-ruby",
        "color" => "#ff0000",
        "head_url" => "http://battlesnake-ruby.herokuapp.com/",
        "taunt" => "battlesnake-ruby"
    }

    return response.to_json
end

post '/move' do
    requestBody = request.body.read

    if requestBody
        requestJson = JSON.parse(requestBody)
    else
        requestJson = {}
    end

    # Dummy response
    response = {
        "move" => "up",
        "taunt" => "going up!"
    }

    return response.to_json
end

post '/end' do
    requestBody = request.body.read

    if requestBody
        requestJson = JSON.parse(requestBody)
    else
        requestJson = {}
    end

    # No response required
    response = {}

    return response.to_json
end
