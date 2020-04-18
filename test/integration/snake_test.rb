require 'test_helper'

class SnakeTest < ActionDispatch::IntegrationTest
  def test_start
    post '/start', params: { game: { id: "game-id-string" } }, as: :json
    assert_response :success
    assert_equal %q({"color":"#6aec87","headType":"silly","tailType":"bolt"}), response.body
  end

  def test_end
    post '/end', params: { game: { id: "game-id-string" } }, as: :json
    assert_response :success
  end

  def test_ping
    post '/ping'
    assert_response :success
  end

  def assert_success_from_payload(payload)
    payload = JSON.parse(payload) if payload.is_a?(String)
    post '/move', params: payload, as: :json
    assert_response :success
    refute_predicate response.body, :empty?

    json = response.parsed_body

    # It returns a valid move
    move = json['move']
    assert_includes %w[up down left right], move

    # That's all it is
    assert_equal({ "move" => move }, json)

    move
  end

  def assert_move_from_payload(expected, payload)
    move = assert_success_from_payload(payload)

    assert_equal expected.to_sym, move.to_sym
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

  def test_move_from_play_battlesnake_com
    assert_success_from_payload <<-JSON
{"game":{"id":"684e74c2-68d6-4e58-a041-9d0c348161bb"},"turn":0,"board":{"height":11,"width":11,"food":[{"x":3,"y":7}],"snakes":[{"id":"gs_KGTDGScKhKSFYB8VPjm3pFJb","name":"snek","health":100,"body":[{"x":1,"y":1},{"x":1,"y":1},{"x":1,"y":1}]},{"id":"gs_tcbXTtDddv4dCVwgmq4r9T9d","name":"snek","health":100,"body":[{"x":9,"y":9},{"x":9,"y":9},{"x":9,"y":9}]}]},"you":{"id":"gs_tcbXTtDddv4dCVwgmq4r9T9d","name":"snek","health":100,"body":[{"x":9,"y":9},{"x":9,"y":9},{"x":9,"y":9}]}}
    JSON
  end

  def test_regression_one_dead_snake
    assert_success_from_payload <<-JSON
{"game":{"id":"1550135655128486549"},"turn":1,"board":{"height":10,"width":10,"food":[{"x":1,"y":1}],"snakes":[{"id":"you","name":"you","health":0,"body":[{"x":2,"y":2}]}]},"you":{"id":"you","name":"you","health":0,"body":[{"x":2,"y":2}]}}
    JSON
  end

  def test_4_player_fixture
    assert_success_from_payload File.read("#{Rails.root}/test/fixtures/4_player_large_game.json")
  end

  def test_8_player_fixture
    assert_success_from_payload File.read("#{Rails.root}/test/fixtures/4_player_large_game.json")
  end

  def test_dont_cause_head_on_tie
    assert_move_from_payload :up, <<-JSON
    {"game":{"id":"a249aa6f-20f7-426c-a5a3-68e7447805df"},"turn":50,"board":{"height":15,"width":15,"food":[{"x":1,"y":13},{"x":5,"y":2},{"x":12,"y":1},{"x":3,"y":1},{"x":10,"y":0},{"x":2,"y":3},{"x":0,"y":14},{"x":11,"y":0},{"x":1,"y":7},{"x":6,"y":11}],"snakes":[{"id":"3e123a3e-ea7b-4fe6-8c08-6a328112c27e","name":"snek","health":98,"body":[{"x":5,"y":6},{"x":5,"y":5},{"x":4,"y":5},{"x":4,"y":6},{"x":4,"y":7},{"x":5,"y":7},{"x":6,"y":7}]},{"id":"ede45648-5e24-4134-9305-b6ba6f955b8d","name":"snek","health":86,"body":[{"x":6,"y":5},{"x":7,"y":5},{"x":7,"y":4},{"x":8,"y":4},{"x":8,"y":5},{"x":8,"y":6},{"x":8,"y":7}]}]},"you":{"id":"ede45648-5e24-4134-9305-b6ba6f955b8d","name":"snek","health":86,"body":[{"x":6,"y":5},{"x":7,"y":5},{"x":7,"y":4},{"x":8,"y":4},{"x":8,"y":5},{"x":8,"y":6},{"x":8,"y":7}]}}
    JSON
  end

  def test_creates_db_records
    start_payload = { "game" => { "id" => "game-id-string" } }
    post '/start', params: start_payload, as: :json
    assert_response :success
    assert_equal %q({"color":"#6aec87","headType":"silly","tailType":"bolt"}), response.body

    game = Storage::Game.find_by!(external_id: "game-id-string")
    assert_equal start_payload, game.initial_state
    assert game.snake_version
    assert_nil game.victory

    move_payload = JSON.parse(File.read("#{Rails.root}/test/fixtures/4_player_large_game.json"))
    post '/move', params: move_payload, as: :json
    assert_response :success

    assert_equal 1, game.moves.count

    end_payload = { "game" => { "id" => "game-id-string" }, "board" => { 'snakes' => [], 'food' => [] }, 'you' => { 'id' => 'you' } }
    post '/end', params: end_payload, as: :json
    assert_response :success
    game.reload
    assert !game.victory
  end
end
