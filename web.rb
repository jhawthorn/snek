require 'sinatra'
require 'json'
post '/start' do
    request.body.rewind
    requestBody = request.body.read
    puts(requestBody)
    if requestBody
        requestJson = JSON.parse(requestBody)
    else
        requestJson = {}
    end

    # Dummy response
    {
        "move" => "up",
        "taunt" => "going up!"
    }.to_json
end
post '/move' do
    request.body.rewind
    requestBody = request.body.read
    #print(requestBody)
    if requestBody
        requestJson = JSON.parse(requestBody)
    else
        requestJson = {}
    end

    # Dummy response
    {
        "name" => "battlesnake-go",
        "color" => "#ff0000",
        "head_url" => "http://battlesnake-go.herokuapp.com/",
        "taunt" => "battlesnake-go"
    }.to_json
end
post '/end' do
    request.body.rewind
    requestBody = request.body.read
    #print(requestBody)
    if requestBody
        requestJson = JSON.parse(request.body.read)
    else
        requestJson = {}
    end

    # No response required
    {}.to_json
end