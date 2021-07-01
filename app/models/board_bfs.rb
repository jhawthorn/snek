class BoardBFS
  attr_reader :board

  attr_reader :tiles
  attr_reader :distance_to_food

  def initialize(board, targets: nil)
    @board = board
    @snakes = board.living_snakes.dup
    @snakes.sort_by! { |snake| -snake.length }
    @targets = targets&.sort_by { |snake| -snake.length } || @snakes

    @tiles = Hash.new(0).compare_by_identity
    @distance_to_food = {}.compare_by_identity

    calculate
  end

  def initial_visited
    visited = Grid.new(board.width, board.height)
    @targets.each do |snake|
      visited.set_all(snake.tail, true)
    end
    unless @snakes == @targets
      (@snakes - @targets).each do |snake|
        visited.set_all(snake.body, true)
      end
    end
    visited
  end

  def initial_queue
    queue = []
    @targets.each do |snake|
      unless @board.out_of_bounds?(snake.head)
        queue << [snake.head.x, snake.head.y, snake]
      end
    end
    queue
  end

  def initial_food
    food = Grid.new(board.width, board.height)
    food.set_all(board.food, true)
    food
  end

  def calculate
    visited = initial_visited()
    food = initial_food()
    next_queue = initial_queue()

    _calculate(visited, food, next_queue)
  end

  def _calculate(visited, food, queue)
    width = @board.width
    width_1 = width - 1
    height_1 = @board.height - 1

    next_queue = queue
    queue = []

    raw_visited = visited.raw_data
    raw_food = food.raw_data

    distance = 0
    until next_queue.empty?
      queue, next_queue = next_queue, queue.clear

      i = 0
      n = queue.size
      while i < n
      #queue.each do |x, y, snake|
        q = queue[i]
        i += 1
        x, y, snake = q[0], q[1], q[2]

        #unless visited.at(x,y)
        unless raw_visited[y * width + x]
          raw_visited[y * width + x] = true
          #visited.set(x, y, true)

          @tiles[snake] += 1

          #if food.at(x,y)
          if raw_food[y * width + x]
            @distance_to_food[snake] ||= distance
          end

          next_queue << [x+1, y, snake] if x < width_1
          next_queue << [x-1, y, snake] if x > 0
          next_queue << [x, y+1, snake] if y < height_1
          next_queue << [x, y-1, snake] if y > 0
        end
      end

      if distance != 0 && !@snakes.empty? && @snakes[0].length >= distance
        i = 0
        n = @snakes.length
        while i < n && (length = (snake = @snakes[i]).length) < distance
          unless (length < distance-1 && snake.body[-distance] == snake.body[-distance-1]) || @distance_to_food[snake]

            segment = snake.body[-distance]
            visited.set(segment.x, segment.y, false)
          end
        end
      end

      distance += 1
    end
  end
end
