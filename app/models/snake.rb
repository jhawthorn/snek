require 'securerandom'

class Snake
  ACTIONS = [:up, :down, :left, :right]

  attr_reader :id, :health, :body, :name
  attr_writer :health

  def initialize(id: nil, health: 100, body: [], name: id)
    @id = id || SecureRandom.hex
    @health = health
    @name = name
    @body = body
  end

  def self.from_json(data)
    new(
      id: data['id'],
      name: data['name'],
      health: data['health'],
      body: data['body'].map { |p| Point.from_json(p) }
    )
  end

  def initialize_copy(other)
    super(other)

    @body = @body.dup
  end

  def alive?
    health > 0
  end

  def head
    @body[0]
  end

  def tail
    @body.drop_while { |x| x == head }
  end

  def length
    @body.length
  end

  def die!
    @health = 0
  end

  def hash
    @id.hash
  end

  def ==(other)
    id == other.id
  end
end
