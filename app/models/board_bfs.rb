class BoardBFS
  attr_reader :board

  attr_reader :voronoi_tiles
  attr_reader :distance_to_food

  def initialize(board)
    @board = board
    @snakes = board.snakes.select(&:alive?)

    @voronoi_tiles = Hash.new(0).compare_by_identity
    @distance_to_food = {}.compare_by_identity

    calculate
  end

  def calculate
    visited = Grid.new(board.width, board.height)
    food = Grid.new(board.width, board.height)

    width_1 = @board.width - 1
    height_1 = @board.height - 1

    next_queue = []

    food.set_all(board.food, true)

    snakes = @snakes.sort_by do |snake|
      -snake.length
    end

    snakes.each do |snake|
      unless board.out_of_bounds?(snake.head)
        next_queue << [snake.head.x, snake.head.y, snake]
      end

      snake.tail.each do |point|
        visited.set(point, true)
      end
    end

    distance = 0
    until next_queue.empty?
      queue = next_queue
      next_queue = []

      queue.each do |x, y, snake|
        next if visited.at(x,y)
        visited.set(x, y, true)

        @voronoi_tiles[snake] += 1

        if food.at(x,y)
          @distance_to_food[snake] ||= distance
        end

        next_queue << [x+1, y, snake] if x < width_1
        next_queue << [x-1, y, snake] if x > 0
        next_queue << [x, y+1, snake] if y < height_1
        next_queue << [x, y-1, snake] if y > 0
      end

      snakes.each do |snake|
        break if distance == 0
        break if snake.length < distance
        next if snake.length < distance-1 && snake.body[-distance] == snake.body[-distance-1]
        next if @distance_to_food[snake]

        visited.set(snake.body[-distance], false)
      end

      distance += 1
    end
  end
end
