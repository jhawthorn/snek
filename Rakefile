require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList['test/**/*_test.rb']
end

task :default => :test

task :profile do
  $LOAD_PATH.unshift "#{__dir__}/lib"
  require "snake"
  require "json"
  require "stackprof"

  fixture = File.read("#{__dir__}/test/fixtures/4_player_large_game.json")
  game = Game.from_json(JSON.parse(fixture))
  MoveDecider.new(game).next_move

  puts "Profiling..."
  output = "stackprof-cpu-snake.dump"
  StackProf.run(mode: :cpu, out: output) do
    20.times do
      MoveDecider.new(game).next_move
    end
  end

  cmd = "bundle exec stackprof #{output}"
  puts cmd
  system cmd
end
