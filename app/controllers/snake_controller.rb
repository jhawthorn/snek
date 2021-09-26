require 'snake'

class SnakeController < ActionController::API
  COLOUR = "#6aec87"
  HEAD_TYPE = "caffeine"
  TAIL_TYPE = "bolt"

  def root
    render json: {
      apiversion: "1",
      author: "jhawthorn",
      color: COLOUR,
      head: HEAD_TYPE,
      tail: TAIL_TYPE
    }
  end

  def start
    json = request_json
    Storage::Game.create(
      external_id: json["game"]["id"],
      initial_state: json,
      snake_version: GitAdder.current_git_sha
    )

    head :ok
  end

  def move
    start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    game = Game.from_json(request_json)
    move_decider = MoveDecider.new(game, scorer: scorer_builder)
    next_move = move_decider.next_move
    finish_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    render json: {
      move: next_move || :down
    }

    if storage_game = Storage::Game.find_by(external_id: request_json["game"]["id"])
      Storage::Move.create!(
        game: storage_game,
        turn: request_json["turn"],
        state: request_json,
        decision: next_move,
        evaluations: [],
        runtime: finish_time - start_time,
        snake_version: GitAdder.current_git_sha
      )
    end
  end

  def end
    if storage_game = Storage::Game.find_by(external_id: request_json["game"]["id"])
      game = Game.from_json(request_json)
      if game.player
        storage_game.update!(victory: true)
      else
        storage_game.update!(victory: false)
      end
    end
    render json: {}
  end

  def ping
    head :ok
  end

  private

  def request_json
    @request_json ||=
      begin
        request_body = request.body.read
        request_body ? JSON.parse(request_body) : {}
      end
  end

  def scorer_builder
    if params[:ml]
      ->(g) { MlScorer.new(g, weights: DefaultWeights) }
    else
      ->(g) { GameScorer.new(g) }
    end
  end
end
