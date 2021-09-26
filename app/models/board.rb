class Board
  attr_reader :snakes, :width, :height, :food, :hazards
  attr_reader :living_snakes

  def initialize(width: 11, height: width, snakes: [], food: [], hazards: [])
    @width = width
    @height = height
    @snakes = snakes
    @living_snakes = snakes.select(&:alive?)
    @food = Set.new(food)
    @hazards = Set.new(hazards)
  end

  def self.from_json(data)
    new(
      width: data['width'],
      height: data['height'],
      snakes: data['snakes'].map { |s| Snake.from_json(s) },
      food: data['food'].map { |f| Point.from_json(f) },
      hazards: data['hazards'].map { |x| Point.from_json(x) }
    )
  end

  def initialize_copy(other)
    super(other)

    @snakes = @snakes.map(&:dup)
    @living_snakes = @snakes.select(&:alive?)
    @food = @food.dup
  end

  def new_grid(default: nil)
    Grid.new(@width, @height, default: default)
  end

  def out_of_bounds?(x, y=nil)
    unless y
      y = x.y
      x = x.x
    end
    x < 0 || y < 0 || x >= @width || y >= @height
  end

  def simulate!(actions)
    snakes = living_snakes

    snakes.each do |snake|
      action = actions[snake.id]

      if action
        new_head = snake.head.move(action)
        snake.body.unshift(new_head)
      else
        # Give it an extra segment in its head.
        # This doesn't really represent how the game would handle this, but at
        # least we preserve snake lengths this way.
        snake.body.unshift(snake.head)
      end
    end

    snakes.each do |snake|
      if @hazards.include?(snake.head)
        snake.health -= 14
      end
      snake.health -= 1
    end

    snakes.each do |snake|
      snake.body.pop
    end

    eaten_food = []
    snakes.each do |snake|
      if @food.include?(snake.head)
        eaten_food << snake.head
        snake.body << snake.body.last
        snake.health = 100
      end
    end
    eaten_food.each do |food|
      @food.delete(food)
    end

    heads = snakes.group_by(&:head)
    walls = Grid.new(width, height)
    snakes.each do |snake|
      walls.set_all(snake.tail, true)
    end

    snakes.each do |snake|
      if out_of_bounds?(snake.head)
        snake.die!
        @living_snakes.delete(snake)
        next
      end

      if walls.at(snake.head.x, snake.head.y)
        snake.die!
        @living_snakes.delete(snake)
        next
      end

      lost_collision =
        heads[snake.head].any? do |other|
          next if other.equal?(snake)

          other.length >= snake.length
        end

      if lost_collision
        snake.die!
        @living_snakes.delete(snake)
        next
      end
    end
  end

  def to_s
    grid = new_grid(default: ' ')

    letters = (?a..?z).to_a
    @snakes.select(&:alive?).each do |snake|
      letter = letters.shift
      grid.set(snake.head.x, snake.head.y, letter.upcase)
      grid.set_all(snake.tail, letter)
    end
    grid.set_all(food, '*')
    grid.to_s(padding: 0)
  end

  def inspect
    "#<Board\n#{to_s}\n>"
  end
end
