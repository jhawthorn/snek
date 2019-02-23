require 'snake'

class SnakeController < ActionController::API
  COLOUR = "#6aec87"
  HEAD_TYPE = "silly"
  TAIL_TYPE = "bolt"

  def start
    render json: {
      color: COLOUR,
      headType: HEAD_TYPE,
      tailType: TAIL_TYPE
    }
  end

  def move
    requestBody = request.body.read
    requestJson = requestBody ? JSON.parse(requestBody) : {}

    game = Game.from_json(requestJson)
    move = MoveDecider.new(game).next_move

    render json: {
      move: move || :down
    }
  end

  def end
    render json: {}
  end

  def ping
    head :ok
  end
end
