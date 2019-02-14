require "test_helper"

require File.expand_path("../web", __dir__)

class WebTest < MiniTest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root
    get '/'
    assert last_response.ok?
  end

  def test_start
    post '/start'
    assert last_response.ok?
    assert_equal %q({"color":"#fff000"}), last_response.body
  end

  def test_end
    post '/end'
    assert last_response.ok?
    assert_equal %q({}), last_response.body
  end

  def test_ping
    post '/start'
    assert last_response.ok?
  end

  def assert_success_from_payload(payload)
    post '/move', payload
    assert last_response.ok?, last_response.body
    refute_predicate last_response.body, :empty?

    json = JSON.parse(last_response.body)

    # It returns a valid move
    move = json['move']
    assert_includes %w[up down left right], move

    # That's all it is
    assert_equal({ "move" => move }, json)
  end

  def test_example_move
    assert_success_from_payload <<~JSON
{
  "game": {
    "id": "game-id-string"
  },
  "turn": 4,
  "board": {
    "height": 15,
    "width": 15,
    "food": [
      {
        "x": 1,
        "y": 3
      }
    ],
    "snakes": [
      {
        "id": "snake-id-string",
        "name": "Sneky Snek",
        "health": 90,
        "body": [
          {
            "x": 1,
            "y": 3
          },
          {
            "x": 2,
            "y": 3
          }
        ]
      }
    ]
  },
  "you": {
    "id": "snake-id-string",
    "name": "Sneky Snek",
    "health": 90
  }
}
  JSON

  end

  def test_move_from_play_battlesnake_io
    assert_success_from_payload <<-JSON
{"game":{"id":"684e74c2-68d6-4e58-a041-9d0c348161bb"},"turn":0,"board":{"height":11,"width":11,"food":[{"x":3,"y":7}],"snakes":[{"id":"gs_KGTDGScKhKSFYB8VPjm3pFJb","name":"snek","health":100,"body":[{"x":1,"y":1},{"x":1,"y":1},{"x":1,"y":1}]},{"id":"gs_tcbXTtDddv4dCVwgmq4r9T9d","name":"snek","health":100,"body":[{"x":9,"y":9},{"x":9,"y":9},{"x":9,"y":9}]}]},"you":{"id":"gs_tcbXTtDddv4dCVwgmq4r9T9d","name":"snek","health":100,"body":[{"x":9,"y":9},{"x":9,"y":9},{"x":9,"y":9}]}}
    JSON
  end

  def test_regression_payload
    assert_success_from_payload <<-JSON
{"game":{"id":"1550135655128486549"},"turn":1,"board":{"height":10,"width":10,"food":[{"x":1,"y":1}],"snakes":[{"id":"you","name":"you","health":0,"body":[{"x":2,"y":2}]}]},"you":{"id":"you","name":"you","health":0,"body":[{"x":2,"y":2}]}}
    JSON
  end
end
