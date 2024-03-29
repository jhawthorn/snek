class Grid
  attr_reader :width, :height

  def initialize(width, height, default: nil, grid: nil)
    @width = width
    @height = height
    @grid = grid || Array.new(height * 16, default)
  end

  def raw_data
    @grid
  end

  def get(x, y=nil)
    unless y
      y = x.y
      x = x.x
    end
    raise "out of bounds: #{x} #{y}" if x < 0 || y < 0 || x >= @width || y >= @height
    @grid[(y * 16) | x]
  end

  def at(x, y)
    @grid[(y * 16) | x]
  end

  def set(x, y, value)
    raise "out of bounds: #{x} #{y}" if x < 0 || y < 0 || x >= @width || y >= @height
    @grid[(y * 16) | x] = value
  end

  def set_all(points, value)
    i = 0
    points = points.to_a
    n = points.length
    while i < n
      point = points[i]
      self.set(point.x, point.y, value)
      i += 1
    end
  end

  def inspect
    values = @grid.map(&:inspect)
    hsize = values.map(&:size).max + 1
    values.map! { |v| v.ljust(hsize) }
    "#<Grid #{@width}x#{@height}\n" + values.each_slice(16).map(&:join).join("\n") + "\n>"
  end

  def to_s(padding: 1, method: :to_s)
    values = @grid.map(&method)
    hsize = values.map(&:size).max + padding
    values.map! { |v| v.ljust(hsize) }
    values.each_slice(16).map(&:join).join("\n")
  end
end
