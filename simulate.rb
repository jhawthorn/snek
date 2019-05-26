require './config/environment'

def random_weights
  Array.new(MlScorer::CARDINALITY) { rand - 0.5 }
end

def new_population(n)
  Array.new(n) { random_weights }
end

def winner_loser_from(a, b, verbose: false)
  weights = {}
  scorer = ->(g) do
    MlScorer.new(g, weights: weights[g.player.id])
  end

  simulation = Simulation.new(scorer: scorer)
  weights[simulation.board.snakes[0].id] = a
  weights[simulation.board.snakes[1].id] = b
  simulation.run(verbose: verbose)

  if simulation.winner.nil?
    # tie? whatever.
    return [a,b].shuffle
  end

  winner = simulation.winner.id
  loser = (simulation.board.snakes.map(&:id) - [winner])[0]

  [weights[winner], weights[loser]]
end

def mutate(weights)
  weights = weights.dup
  rand(3).times do
    weights[rand(10)] += (rand - 0.5) * 0.1
  end
  weights
end

def eliminate(initial_pop, desired)
  pop = initial_pop.dup

  until pop.size <= desired
    matches = pop.shuffle.each_slice(2).to_a
    new_pop =
      Parallel.map(matches, in_processes: 8) do |(a, b)|
        winner, _loser = winner_loser_from(a, b)

        winner
      end
    pop = new_pop
  end

  pop
end

i = 0
pop = new_population(16)
50.times do
  puts "Round #{i}"
  i += 1
  pop = eliminate(pop, 8)
  pop += pop.map { |x| mutate(x) }

  # Show one round for fun
  winner_loser_from(*pop.sample(2), verbose: true)
end
best = eliminate(pop, 1)[0]
puts "best: #{best.inspect}"
