ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def game_fixture(filename)
    path = "#{__dir__}/fixtures/#{filename}"
    data = File.read(path)
    Game.from_json(JSON.load(data))
  end
end
