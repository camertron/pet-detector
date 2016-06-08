require 'simple-graph'

module PetDetector
  class EntityMatrix < Matrix
    def to_distance_map
      Hash.new { |h, k| h[k] = {} }.tap do |result|
        graph.vertices.each_pair do |from_entity, from_vertex|
          graph.vertices.each do |to_entity, to_vertex|
            next if from_entity == to_entity
            result[from_entity][to_entity] = graph.shortest_path(from_entity, to_entity).size - 1
          end
        end
      end
    end

    private

    def graph
      @graph ||= SimpleGraph::Graph.new.tap do |graph|
        each do |x, y, entity|
          graph.add_vertex(entity)
          add_left_neighbors(graph, entity, x, y)
          add_right_neighbors(graph, entity, x, y)
          add_top_neighbors(graph, entity, x, y)
          add_bottom_neighbors(graph, entity, x, y)
        end
      end
    end

    def add_left_neighbors(graph, entity, x, y)
      if entity.directions.left?
        graph.add_vertex(left_neighbor(x, y))
        graph.add_edge(entity, left_neighbor(x, y))
      end
    end

    def add_right_neighbors(graph, entity, x, y)
      if entity.directions.right?
        graph.add_vertex(right_neighbor(x, y))
        graph.add_edge(entity, right_neighbor(x, y))
      end
    end

    def add_top_neighbors(graph, entity, x, y)
      if entity.directions.top?
        graph.add_vertex(top_neighbor(x, y))
        graph.add_edge(entity, top_neighbor(x, y))
      end
    end

    def add_bottom_neighbors(graph, entity, x, y)
      if entity.directions.bottom?
        graph.add_vertex(bottom_neighbor(x, y))
        graph.add_edge(entity, bottom_neighbor(x, y))
      end
    end

    def top_neighbor(x, y)
      if y > 0
        self[x, y - 1]
      end
    end

    def bottom_neighbor(x, y)
      if y < height - 1
        self[x, y + 1]
      end
    end

    def left_neighbor(x, y)
      if x > 0
        self[x - 1, y]
      end
    end

    def right_neighbor(x, y)
      if x < width - 1
        self[x + 1, y]
      end
    end

    def entities_to_find
      flat_map { |x, y, entity| entity }.select do |entity|
        entity.house? || entity.pet?
      end
    end
  end
end
