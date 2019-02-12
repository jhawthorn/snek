require "test_helper"

require File.expand_path("../web", __dir__)

class WebTest < MiniTest::Unit::TestCase

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

  FULL_MOVE_PAYLOAD = <<~JSON
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
          }
        ]
      }
    ]
  },
  "you": {
    "id": "snake-id-string",
    "name": "Sneky Snek",
    "health": 90,
    "body": [
      {
        "x": 1,
        "y": 3
      }
    ]
  }
}
  JSON

  def test_move
    post '/move', FULL_MOVE_PAYLOAD
    assert last_response.ok?, last_response.body
    refute_predicate last_response.body, :empty?

    json = JSON.parse(last_response.body)

    # It returns a valid move
    assert_includes %w[up down left right], json['move']

    # That's all it is
    assert_equal({ "move" => json['move'] }, json)
  end
end
