# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task :profile do
  $LOAD_PATH.unshift "#{__dir__}/lib"
  require "snake"
  require "json"
  require "stackprof"

  fixture = File.read("#{__dir__}/test/fixtures/8_player_large_game.json")
  game = Game.from_json(JSON.parse(fixture))
  MoveDecider.new(game).next_move

  puts "Profiling..."
  output = "stackprof-cpu-snake.dump"
  StackProf.run(mode: :cpu, out: output) do
    10.times do
      MoveDecider.new(game).next_move
    end
  end

  cmd = "bundle exec stackprof #{output}"
  puts cmd
  system cmd
end
