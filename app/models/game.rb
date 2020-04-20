require 'securerandom'

class Game
  attr_reader :id, :turn, :self_id, :board

  def initialize(id: nil, turn: 0, self_id:, board:)
    @id = id || SecureRandom.hex
    @turn = turn
    @self_id = self_id
    @board = board
  end

  def self.from_json(data)
    new(
      id: data['game']['id'],
      turn: data['turn'],
      self_id: data['you']['id'],
      board: Board.from_json(data['board'])
    )
  end

  def initialize_copy(other)
    @board = @board.dup
    @player = nil
    @enemies = nil
  end

  def snakes
    @board.snakes
  end

  def player
    @player ||= snakes.detect { |s| s.id == @self_id }
  end

  def enemies
    @enemies ||= snakes - [player]
  end

  def simulate(actions)
    game = dup
    game.simulate!(actions)
    game
  end

  def simulate!(actions)
    board.simulate!(actions)
  end
end
