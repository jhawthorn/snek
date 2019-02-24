class Storage::Game < ApplicationRecord
  serialize :initial_state, JSON

  has_many :moves

  validates :initial_state, :external_id, :snake_version, presence: true

  def human_victory
    { true => "won", false => "lost" }[victory]
  end

  def human_result
    return if victory.nil?
    "#{human_victory} in #{moves.count} turns"
  end

  def external_url
    "https://play.battlesnake.io/g/#{external_id}/"
  end

  def gif_url
    "http://exporter.battlesnake.io/games/#{external_id}?output=gif"
  end

  def turn_image_url(turn)
    "http://exporter.battlesnake.io/games/#{external_id}/frames/#{turn}?output=png"
  end

  def to_param
    external_id
  end
end
