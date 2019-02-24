class Storage::Game < ApplicationRecord
  serialize :initial_state, JSON

  has_many :moves

  validates :initial_state, :external_id, :snake_version, presence: true
end
