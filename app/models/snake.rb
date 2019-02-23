require 'securerandom'

class Snake
  ACTIONS = [:up, :down, :left, :right]

  attr_reader :id, :health, :body
  attr_writer :health

  def initialize(id: nil, health: 100, body: [])
    @id = id || SecureRandom.hex
    @health = health
    @body = body
  end

  def self.from_json(data)
    new(
      id: data['id'],
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
