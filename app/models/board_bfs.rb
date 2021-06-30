class BoardBFS
  attr_reader :board

  attr_reader :tiles
  attr_reader :distance_to_food

  def initialize(board, targets: nil)
    @board = board
    @snakes = board.snakes.dup
    @snakes.select!(&:alive?)
    @snakes.sort_by! { |snake| -snake.length }
    @targets = targets&.sort_by { |snake| -snake.length } || @snakes

    @tiles = Hash.new(0).compare_by_identity
    @distance_to_food = {}.compare_by_identity

    calculate
  end

  def calculate
    visited = Grid.new(board.width, board.height)
    food = Grid.new(board.width, board.height)

    width_1 = @board.width - 1
    height_1 = @board.height - 1

    queue = []
    next_queue = []

    food.set_all(board.food, true)

    @targets.each do |snake|
      visited.set_all(snake.tail, true)
    end
    unless @snakes == @targets
      (@snakes - @targets).each do |snake|
        visited.set_all(snake.body, true)
      end
    end

    @targets.each do |snake|
      unless board.out_of_bounds?(snake.head)
        next_queue << [snake.head.x, snake.head.y, snake]
      end
    end

    distance = 0
    until next_queue.empty?
      queue, next_queue = next_queue, queue.clear

      queue.each do |x, y, snake|
        next if visited.at(x,y)
        visited.set(x, y, true)

        @tiles[snake] += 1

        if food.at(x,y)
          @distance_to_food[snake] ||= distance
        end

        next_queue << [x+1, y, snake] if x < width_1
        next_queue << [x-1, y, snake] if x > 0
        next_queue << [x, y+1, snake] if y < height_1
        next_queue << [x, y-1, snake] if y > 0
      end

      @snakes.each do |snake|
        break if distance == 0
        length = snake.length
        break if length < distance
        next if length < distance-1 && snake.body[-distance] == snake.body[-distance-1]
        next if @distance_to_food[snake]

        segment = snake.body[-distance]
        visited.set(segment.x, segment.y, false)
      end unless @snakes.empty? || @snakes[0].length < distance

      distance += 1
    end
  end
end
