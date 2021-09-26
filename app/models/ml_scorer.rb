class MlScorer
  SCORE_MIN = -999999999
  SCORE_MAX =  999999999

  SHAPE = [10, 10, 6, 4, 1]
  EDGES = SHAPE.each_cons(2).map{|a,b| a * b }
  CARDINALITY = EDGES.sum

  attr_reader :bfs, :player

  def initialize(game, bfs: nil, weights:)
    @game = game
    @player = @game.player
    if @player.alive?
      @bfs = bfs || BoardBFS.new(@game.board)
      @reachable_bfs = BoardBFS.new(@game.board, [@game.player])
    end

    weights = weights.dup
    @weights = EDGES.map do |n|
      weights.shift(n)
    end
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

      nodes = nodes.map{ |x| activation(x) }
    end

    nodes[0]
  end

  def activation(x)
    x > 0.0 ? x : 0.0
  end

  def score_info
    enemies = @game.enemies.select(&:alive?)

    player_food_distance = @bfs.distance_to_food[player] || @game.board.width
    enemy_food_distance = enemies.map {|e| @bfs.distance_to_food[e] || @game.board.width }

    player_voronoi = @bfs.tiles[player]
    enemy_voronoi = enemies.map{|e| @bfs.tiles[e] }.max

    player_reachable = @reachable_bfs.tiles[player]

    hazards = @game.board.hazards
    in_hazard = hazards.include?(player.head)
    total_hazards = hazards.size

    [
      player.length,
      player.health,

      in_hazard ? 0 : 1,
      total_hazards,

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
