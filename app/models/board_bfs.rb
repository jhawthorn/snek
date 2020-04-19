class BoardBFS
  attr_reader :board

  attr_reader :tiles
  attr_reader :distance_to_food

  def initialize(board, targets: nil)
    @board = board
    @snakes = board.snakes.select(&:alive?).sort_by do |snake|
      -snake.length
    end
    @targets = targets || @snakes

    @tiles = Hash.new(0).compare_by_identity
    @distance_to_food = {}.compare_by_identity

    calculate
  end

  def calculate
    visited = Cnek::Grid.new(board.width, board.height)
    food = Cnek::Grid.new(board.width, board.height)

    width_1 = @board.width - 1
    height_1 = @board.height - 1

    queue = Cnek::Queue.new(visited)
    next_queue = Cnek::Queue.new(visited)

    food.set_all(board.food, true)

    @targets.each do |snake|
      visited.set_all(snake.tail, true)
    end
    (@snakes - @targets).each do |snake|
      visited.set_all(snake.body, true)
    end

    @targets.sort_by(&:length).reverse_each do |snake|
      unless board.out_of_bounds?(snake.head)
        next_queue.add(snake.head.x, snake.head.y, snake)
      end
    end

    distance = 0
    until next_queue.empty?
      queue, next_queue = next_queue, queue.clear

      queue.each do |x, y, snake|
        @tiles[snake] += 1

        if food.at(x,y)
          @distance_to_food[snake] ||= distance
        end

        next_queue.add(x+1, y, snake) if x < width_1
        next_queue.add(x-1, y, snake) if x > 0
        next_queue.add(x, y+1, snake) if y < height_1
        next_queue.add(x, y-1, snake) if y > 0
      end

      @snakes.each do |snake|
        break if distance == 0
        break if snake.length < distance
        next if snake.length < distance-1 && snake.body[-distance] == snake.body[-distance-1]
        next if @distance_to_food[snake]

        segment = snake.body[-distance]
        visited.set(segment.x, segment.y, false)
      end

      distance += 1
    end
  end
end
