class MlScorer
  SCORE_MIN = -999999999
  SCORE_MAX =  999999999

  SHAPE = [8, 4, 1]
  EDGES = SHAPE.each_cons(2).map{|a,b| a * b }
  CARDINALITY = EDGES.sum

  attr_reader :bfs

  def initialize(game, bfs: nil, weights:)
    @game = game
    @bfs = bfs || BoardBFS.new(@game.board)
    @reachable_bfs = BoardBFS.new(@game.board, targets: [@game.player])

    weights = weights.dup
    @weights = EDGES.map do |n|
      weights.shift(n)
    end
  end

  def player
    @player ||= @game.player
  end

  def lost?
    !player.alive?
  end

  def won?
    @game.enemies.any? && @game.enemies.none?(&:alive?)
  end

  def trivial_score?
    lost? || won?
  end

  def score
    return SCORE_MIN if lost?
    return SCORE_MAX if won?

    nodes = score_info

    SHAPE[1..-1].each_with_index do |layer_size, layer|
      weights = @weights[layer].dup
      nodes = (0...layer_size).map do |i|
        nodes.map do |value|
          value * weights.shift
        end.sum
      end
    end

    nodes[0]
  end

  def score_info
    enemies = @game.enemies.select(&:alive?)

    player_food_distance = @bfs.distance_to_food[player] || @game.board.width
    enemy_food_distance = enemies.map {|e| @bfs.distance_to_food[e] || @game.board.width }

    player_voronoi = @bfs.tiles[player]
    enemy_voronoi = enemies.map{|e| @bfs.tiles[e] }.max

    player_reachable = @reachable_bfs.tiles[player]


    [
      player.length,
      player.health,

      #enemies.count,
      #enemies.map(&:length).max || 0,
      enemies.sum(&:length),

      player_food_distance,
      enemy_food_distance.max,

      player_voronoi,
      enemy_voronoi,

      player_reachable,
    ]
  end
end
