class GameScorer
  SCORE_MIN = -999999999
  SCORE_MAX =  999999999

  attr_reader :bfs

  def initialize(game, bfs: nil)
    @game = game
    @bfs = bfs || BoardBFS.new(@game.board)
    @reachable_bfs = BoardBFS.new(@game.board, [@game.player])
  end

  def score_description
    player = @game.player
    return { dead: SCORE_MIN } unless player.alive?

    live_enemies = @game.enemies.select { |x| x.alive? }

    # If there was at least one enemy, but now is dead, victory
    # Necessary so we still somewhat play a single player game
    if live_enemies.empty? && @game.enemies.any?
      return { won: SCORE_MAX }
    end

    # If we're 100% backed into a corner
    # This basically saves us one turn of simulation
    if @bfs.tiles[player] <= 1
      return { dies_next: SCORE_MIN + 10 }
    end

    distance_to_food = @bfs.distance_to_food[player] || @game.board.width * 2
    if distance_to_food > 10
      distance_to_food /= 100.0
      distance_to_food += 10
    end

    # Make it urgent if we are near death
    distance_to_food *= 10 if player.health < 20

    enemies = live_enemies

    player_voronoi = @bfs.tiles[player]
    player_reachable = @reachable_bfs.tiles[player]
    player_reachable = 10 if player_reachable > 10

    {
      length: 25 * player.length,
      health: 1 * player.health,
      enemy_remaining: -50 * enemies.count,
      enemy_max_length: -1 * (enemies.map { |x| x.length }.max || 0),
      enemy_length: -1 * enemies.sum { |x| x.length },

      player_voronoi: 1 * player_voronoi,
      player_reachable: 2 * player_reachable,
      player_near_food: -1 * distance_to_food,
    }
  end

  def score
    score_description.values.compact.sum
  end
end
