require "test_helper"
require "set"

require File.expand_path("../web", __dir__)

class PointTest < MiniTest::Test
  def test_from_json
    point = Point.from_json({'x' => 123, 'y' => 456})
    assert_equal 123, point.x
    assert_equal 456, point.y
  end

  def test_equality
    a = Point.new(1, 2)
    b = Point.new(1, 2)
    assert_equal a, b
    assert_equal b, a
  end

  def test_hashability
    a = Point.new(1, 2)
    b = Point.new(1, 2)

    set = Set.new([a])
    assert_includes set, a
    assert_includes set, b
  end
end
