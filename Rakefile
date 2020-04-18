# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

task :profile => :environment do
  require "stackprof"

  fixture = File.read("#{__dir__}/test/fixtures/8_player_large_game.json")
  game = Game.from_json(JSON.parse(fixture))

  time = Benchmark.ms { MoveDecider.new(game).next_move }
  runs = (10000 / time).round
  runs = 10 if runs < 10
  puts "testing against #{runs} runs"
  mode = ENV.fetch("STACKPROF_MODE", "cpu")

  puts "Profiling..."
  output = "stackprof-#{mode}-snake.dump"
  StackProf.run(mode: mode.to_sym, out: output) do
    runs.times do
      MoveDecider.new(game).next_move
    end
  end

  cmd = "bundle exec stackprof #{output}"
  puts cmd
  system cmd
end

task simulate: :environment do
  Simulation.new.run(verbose: true)
end
