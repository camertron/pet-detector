module PetDetector
  class GraphSolver
    MAX_CAR_CAPACITY = 4

    attr_reader :entity_matrix, :gas

    def initialize(entity_matrix, gas)
      @entity_matrix = entity_matrix
      @gas = gas
    end

    def solve
      solve_helper(car, [], entities, gas, [])
    end

    private

    def solve_helper(last_entity, car_pets, remaining_entities, current_gas, current_path)
      return current_path if car_pets.empty? && remaining_entities.empty?
      candidates = get_candidates(car_pets, remaining_entities)

      candidates.each do |candidate|
        # do we have enough gas to get here?
        gas = current_gas - distance_between(last_entity, candidate)
        return nil if gas < 0

        if candidate.house?
          # drop off a pet
          corresponding_pet = house_pet_map[candidate]

          if car_pets.include?(corresponding_pet)
            car_pets -= [corresponding_pet]
          end
        elsif candidate.pet?
          # pick up a pet
          car_pets += [candidate]
        end

        result = solve_helper(
          candidate, car_pets, remaining_entities - [candidate], gas,
          current_path + [candidate]
        )

        return result if result
      end

      nil
    end

    def get_candidates(car_pets, remaining_entities)
      if car_pets.size == 0
        # no pets in car means we can only visit pets
        remaining_entities.select(&:pet?)
      elsif car_pets.size == MAX_CAR_CAPACITY
        # max pets means we can only visit houses
        remaining_entities.select(&:house?)
      else
        # can visit either a house or a pet, but only houses that correspond
        # to pets we currently have in the car
        remaining_entities.select do |entity|
          if entity.house?
            car_pets.include?(house_pet_map[entity])
          elsif entity.pet?
            true
          end
        end
      end
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

    def house_pet_map
      @house_pet_map ||= entities.each_with_object({}) do |entity, ret|
        next unless entity.house?
        pet = entities.find { |e| e.pet? && e.name == entity.name }
        ret[entity] = pet
      end
    end
  end
end
