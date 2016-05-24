require 'simple-graph'

class Solver
  attr_reader :entities, :gas

  def initialize(entities, gas)
    @entities = entities
    @gas = gas
  end

  def solve
    @min_remaining = 14
    x, y, car = entities.find { |x, y, entity| entity.car? }
    search(car, [], [], entities_to_find) do |path|
      binding.pry
    end
  end

  private

  def search(entity, path, pets_on_board, entities_remaining, &block)
    @min_remaining = entities_remaining.size if entities_remaining.size < @min_remaining
    puts "path: #{path.size}, pets: #{pets_on_board.size}, remaining: #{entities_remaining.size} (min: #{@min_remaining})"
    return nil if path.size > gas
    return nil if pets_on_board.size > 4
    yield path if entities_remaining.size == 0

    graph.vertices[entity].neighbors.each_pair do |_, neighbor_vertex|
      neighbor_entity = neighbor_vertex.value
      next if path.count { |elem| elem == neighbor_entity } >= 2
      # next if neighbor_entity == path.last || neighbor_entity == path[-2] #|| neighbor_entity == path[-3] || neighbor_entity == path[-4]

      new_pets_on_board = if neighbor_entity.pet?
        pets_on_board + [neighbor_entity]
      else
        pets_on_board
      end

      new_entities_remaining = if neighbor_entity.pet?
        entities_remaining - [neighbor_entity]
      elsif neighbor_entity.house?
        pet = pets_on_board.find do |pet|
          pet.name == neighbor_entity.name
        end

        if pet
          new_pets_on_board.delete(pet)
          entities_remaining - [pet]
        else
          entities_remaining
        end
      else
        entities_remaining
      end

      search(
        neighbor_entity, path + [neighbor_entity],
        new_pets_on_board, new_entities_remaining, &block
      )
    end
  end

  def graph
    @graph ||= entities.to_graph
  end

  def entities_to_find
    entities.flat_map { |x, y, entity| entity }.select do |entity|
      entity.house? || entity.pet?
    end
  end
end
