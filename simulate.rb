require './config/environment'

MUTATION_RATE = 0.1

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
  weights[rand(MlScorer::CARDINALITY)] = rand - 0.5
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

def reproduce(initial_pop, desired)
  pop = initial_pop.dup

  while pop.size < desired
    a, b = initial_pop.sample(2)
    child = a.zip(b).map(&:sample)
    pop << child
  end

  pop.map do |member|
    if rand < MUTATION_RATE
      mutate(member)
    else
      member
    end
  end
end

i = 0
POP = 16
ADVANCE = 8
pop = new_population(POP)
ROUNDS = 50
ROUNDS.times do
  puts "Round #{i}"
  i += 1
  pop = eliminate(pop, ADVANCE)

  # Show one round for fun
  winner_loser_from(*pop.sample(2), verbose: true)

  pop = reproduce(pop, POP)
end
best = eliminate(pop, 1)[0]
puts "best: #{best.inspect}"
