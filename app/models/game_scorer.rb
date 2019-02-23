class GameScorer
  SCORE_MIN = -999999999
  SCORE_MAX =  999999999

  attr_reader :bfs

  def initialize(game, bfs: nil)
    @game = game
    @bfs = bfs || BoardBFS.new(@game.board)
  end

  def score
    player = @game.player
    return SCORE_MIN unless player.alive?

    # If there was at least one enemy, but now is dead, victory
    # Necessary so we still somewhat play a single player game
    if @game.enemies.any? && @game.enemies.none?(&:alive?)
      return SCORE_MAX
    end

    # If we're 100% backed into a corner
    # This basically saves us one turn of simulation
    if @bfs.voronoi_tiles[player] <= 1
      return SCORE_MIN + 10
    end

    distance_to_food = @bfs.distance_to_food[player] || @game.board.width * 2
    if distance_to_food > 10
      distance_to_food /= 100.0
      distance_to_food += 10
    end

    # Make it urgent if we are near death
    distance_to_food *= 10 if player.health < 20

    enemies = @game.enemies.select(&:alive?)

    [
        50 * player.length,
         1 * player.health,
      -250 * enemies.count,
        -1 * (enemies.map(&:length).max || 0),
        -1 * enemies.sum(&:length),

         1 * @bfs.voronoi_tiles[player],
        -1 * distance_to_food
    ].sum
  end
end
