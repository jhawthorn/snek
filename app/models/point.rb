class Point
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def self.from_json(data)
    new(
      data['x'],
      data['y']
    )
  end

  def move(direction)
    case direction
    when :up
      Point.new(x, y+1)
    when :down
      Point.new(x, y-1)
    when :left
      Point.new(x-1, y)
    when :right
      Point.new(x+1, y)
    end
  end

  def ==(other)
    @x == other.x && @y == other.y
  end

  def eql?(other)
    @x == other.x && @y == other.y
  end

  def to_a
    [x, y]
  end

  def hash
    (@y * 256) + @x
  end

  def inspect
    "(#{x}, #{y})"
  end
end
