# frozen_string_literal: true

class Storage::Game < ApplicationRecord
  module GzipJSON
    extend self

    def load(data)
      if data && data.getbyte(0) == 31 && data.getbyte(1) == 139
        data = Zlib.gunzip(data)
      end
      JSON.load(data)
    end

    def dump(data)
      Zlib.gzip(JSON.dump(data))
    end
  end

  serialize :initial_state, JSON
  serialize :move_data, GzipJSON

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
    "https://play.battlesnake.com/g/#{external_id}/"
  end

  def gif_url
    "https://exporter.battlesnake.com/games/#{external_id}/gif"
  end

  def turn_image_url(turn)
    "https://exporter.battlesnake.com/games/#{external_id}/frames/#{turn}/gif"
  end

  def to_param
    external_id
  end

  def frame_data
    return @frame_data if defined?(@frame_data)

    offset = 0
    @frame_data = []
    loop do
      uri = URI.parse("https://engine.battlesnake.com/games/#{external_id}/frames?offset=#{offset}")
      response = Net::HTTP.get_response(uri)
      if Net::HTTPOK === response
        data = JSON.parse(response.body)
        @frame_data.concat data["Frames"]

        if data["Count"] < 100
          return @frame_data
        end

        offset += 100
      else
        @frame_data = nil
        return
      end
    end
  end
end
