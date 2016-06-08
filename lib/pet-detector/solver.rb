module PetDetector
  class Solver
    MAX_CAR_CAPACITY = 4
    POPULATION_SIZE = 50
    SURVIVAL_RATE = 0.10
    MUTATION_RATE = 0.90
    MAX_MUTATIONS = 5
    EVOLUTIONS_UNTIL_EXTINCTION = 500

    attr_reader :entity_matrix, :gas

    def initialize(entity_matrix, gas)
      @entity_matrix = entity_matrix
      @gas = gas
    end

    def solve
      count = 0
      population = []

      loop do
        if count % EVOLUTIONS_UNTIL_EXTINCTION == 0
          population = sort(generate(POPULATION_SIZE))
        end

        if population.first.first == gas
          return population.first.last
        end

        population = next_generation(population)
        count += 1
      end
    end

    private

    def next_generation(population)
      best = population.shift
      population = population[0..(population.size * SURVIVAL_RATE)]
      ((1 - SURVIVAL_RATE) * POPULATION_SIZE).round.times do
        population << dup_org(best)
      end
      mutate_pop!(population)
      population.reject! { |fitness, _| fitness == 9999 }
      population += generate(POPULATION_SIZE - population.size)
      population << best
      sort(population)
    end

    def dup_org(org)
      [org[0], org[1].dup]
    end

    def mutate_pop!(population)
      (population.size * MUTATION_RATE).round.times do
        (rand(MAX_MUTATIONS) + 1).times do
          mutate_org!(population[rand(population.size)])
        end
      end
    end

    def mutate_org!(organism)
      entities = organism[1]
      first = rand(entities.size)
      second = rand(entities.size)
      entities[first], entities[second] = entities[second], entities[first]
      organism[0] = fitness(entities)
    end

    def sort(population)
      population.sort do |(first_fitness, first), (second_fitness, second)|
        first_fitness <=> second_fitness
      end
    end

    def generate(num)
      [].tap do |organisms|
        until organisms.size == num
          candidate = houses_and_pets.shuffle
          organisms << [fitness(candidate), candidate]
        end
      end
    end

    def fitness(entities)
      return 9999 unless valid_order?(entities)
      last_entity = car
      sum = 0

      entities.each do |entity|
        sum += distance_between(last_entity, entity)
        last_entity = entity
      end

      sum
    end

    def valid_order?(entities)
      return false if entities.first.house?

      on_board = []
      remaining = entities.dup

      entities.each do |entity|
        if entity.pet?
          on_board << entity
          remaining.delete(entity)
        elsif entity.house?
          if pet = on_board.find { |obe| obe.pet? && obe.name == entity.name }
            on_board.delete(pet)
            remaining.delete(entity)
          end
        end

        return false if on_board.size > MAX_CAR_CAPACITY
      end

      remaining.empty?
    end

    def distance_between(first_entity, second_entity)
      entity_distance_map[first_entity][second_entity]
    end

    def entity_distance_map
      @entity_distance_map ||= entity_matrix.to_distance_map
    end

    def car
      @car ||= entities.find(&:car?)
    end

    def entities
      @entities ||= entity_matrix.flat_map { |x, y, entity| entity }
    end

    def houses_and_pets
      @houses_and_pets ||=
        entities.select { |entity| entity.house? || entity.pet? }
    end
  end
end
