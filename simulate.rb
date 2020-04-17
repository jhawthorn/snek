require './config/environment'

CARDINALITY = MlScorer::CARDINALITY
MUTATION_RATE = 0.05
N_PROC=16

def random_weights
  Array.new(CARDINALITY) { rand - 0.5 }
end

def new_population(n)
  Array.new(n) { random_weights }
end

def winner_losers_from(*snakes, verbose: false)
  raise unless snakes.size >= 2

  weights = {}
  scorer = ->(g) do
    w = weights[g.player.id]
    if w
      MlScorer.new(g, weights: w)
    else
      GameScorer.new(g)
    end
  end

  #size = [7,11,19].sample
  size = 11
  simulation = Simulation.new(scorer: scorer, snake_count: snakes.size, size: size)

  snakes.size.times do |i|
    weights[simulation.board.snakes[i].id] = snakes[i]
  end
  simulation.run(verbose: verbose)

  if simulation.winner.nil?
    # tie? whatever.
    winner = snakes.sample
    return [winner, (snakes - [winner])]
  end

  winner_id = simulation.winner.id
  winner = weights.delete(winner_id)
  losers = weights.values

  [winner, losers]
end

def mutate(weights)
  weights.map do |original|
    if rand < MUTATION_RATE
      rand - 0.5
    else
      original
    end
  end
end

def eliminate(initial_pop, desired)
  pop = initial_pop.dup

  until pop.size <= desired
    matches = pop.shuffle.each_slice(2).to_a
    new_pop =
      Parallel.map(matches, in_processes: N_PROC, progress: "Simulating") do |(a, b)|
        winner, _loser = winner_losers_from(a, b)

        winner
      end
    pop = new_pop
  end

  pop
end

def reproduce(initial_pop, desired)
  pop = initial_pop.dup

  while pop.size < desired
    a, b = initial_pop.sample(2)
    child = a.zip(b).map(&:sample)
    pop << child
  end

  pop.map do |member|
    mutate(member)
  end
end

i = 0
POP = 64
ADVANCE = 16
pop = new_population(POP)

ROUNDS = 500
ROUNDS.times do
  puts "Round #{i}"
  i += 1
  pop = eliminate(pop, ADVANCE)

  # Show one round for fun
  winner, _ = winner_losers_from(*pop.sample(2), verbose: true)
  puts "vs. hand tuned scorer..."
  winner, _= winner_losers_from(winner, nil)
  puts winner.nil? ? "  lost" : "  won"

  pop = reproduce(pop, POP)
end
best = eliminate(pop, 1)[0]
puts "best: #{best.inspect}"
puts
puts "Testing against hand tuned scorer"

ROUNDS_VS_TUNED = 100
wins = Parallel.map(ROUNDS_VS_TUNED.times, in_processes: N_PROC, progress: "Simulating") do |seed|
  Kernel.srand

  !!winner_losers_from(best, nil)[0]
end.count(true)
losses = ROUNDS_VS_TUNED - wins

puts "  wins: #{wins}, losses: #{losses}"
