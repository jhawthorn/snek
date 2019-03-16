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
  5.times do
    weights[rand(10)] += (rand - 0.5) * 0.1
  end
  weights
end

def eliminate(initial_pop, desired)
  pop = initial_pop.dup
  eliminations = Hash.new(0)

  i = 1
  until pop.size <= desired
    puts "Match #{i} - #{pop.size} remain"
    i += 1
    a, b = pop.sample(2)
    _winner, loser = winner_loser_from(a, b)

    eliminations[loser] += 1
    if eliminations[loser] >= 2
      pop.delete(loser)
    end
  end

  pop
end

i = 0
pop = new_population(10)
50.times do
  puts "Round #{i}"
  i += 1
  pop = eliminate(pop, 5)
  pop += pop.map { |x| mutate(x) }

  # Show one round for fun
  winner_loser_from(*pop.sample(2), verbose: true)
end
best = eliminate(pop, 1)[0]
puts "best: #{best.inspect}"
