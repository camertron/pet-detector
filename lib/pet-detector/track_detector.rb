module PetDetector
  class DirectionBools
    attr_reader :x, :y
    attr_accessor :top, :bottom, :left, :right
    attr_accessor :matrix

    alias_method :top?, :top
    alias_method :bottom?, :bottom
    alias_method :left?, :left
    alias_method :right?, :right

    def initialize(top, bottom, left, right, x, y)
      @top = top
      @bottom = bottom
      @left = left
      @right = right
      @x = x
      @y = y
    end

    def top_neighbor
      if y > 0
        matrix[x, y - 1]
      end
    end

    def bottom_neighbor
      if y < matrix.height - 1
        matrix[x, y + 1]
      end
    end

    def left_neighbor
      if x > 0
        matrix[x - 1, y]
      end
    end

    def right_neighbor
      if x < matrix.width - 1
        matrix[x + 1, y]
      end
    end

    def to_h
      { top: top, bottom: bottom, left: left, right: right }
    end
  end

  class TrackDetector
    COLOR_RANGE = ColorRange.new(0..30, 0..30, 0..30)

    # an offset to shift the x probe slightly to the right so the blacker
    # left-hand side of the rooves of houses don't interfere
    X_OFFSET = 10

    # track must exist within this percentage of the left, right, top, and bottom
    # quadrant boundaries
    TOLERANCE_PCT = 0.22

    attr_reader :grid

    def initialize(grid)
      @grid = grid
    end

    def detect_directions
      matrix = calc_track_directions
      resolve_directions(matrix)
      matrix
    end

    private

    def resolve_directions(matrix)
      matrix.each do |x, y, direction|
        resolve_top(direction)
        resolve_bottom(direction)
        resolve_left(direction)
        resolve_right(direction)
      end
    end

    def resolve_top(direction)
      if neighbor = direction.top_neighbor
        direction.top = true if neighbor.bottom?
      else
        direction.top = false
      end
    end

    def resolve_bottom(direction)
      if neighbor = direction.bottom_neighbor
        direction.bottom = true if neighbor.top?
      else
        direction.bottom = false
      end
    end

    def resolve_left(direction)
      if neighbor = direction.left_neighbor
        direction.left = true if neighbor.right?
      else
        direction.left = false
      end
    end

    def resolve_right(direction)
      if neighbor = direction.right_neighbor
        direction.right = true if neighbor.left?
      else
        direction.right = false
      end
    end

    def calc_track_directions
      matrix = Matrix.new(
        grid.map_quadrants do |x, y, quad|
          DirectionBools.new(
            detect_top(quad), detect_bottom(quad),
            detect_left(quad), detect_right(quad),
            x, y
          )
        end
      )

      matrix.each do |x, y, item|
        item.matrix = matrix
      end

      matrix
    end

    def detect_left(quad)
      x_start = quad.rect.left
      y_start = quad.rect.top + (quad.rect.height / 2)
      x, y = probe(quad, x_start, y_start, 1, 0)
      x <= quad.rect.left + (quad.rect.width * TOLERANCE_PCT)
    end

    def detect_right(quad)
      x_start = quad.rect.right
      y_start = quad.rect.top + (quad.rect.height / 2)
      x, y = probe(quad, x_start, y_start, -1, 0)
      x >= quad.rect.right - (quad.rect.width * TOLERANCE_PCT)
    end

    def detect_top(quad)
      x_start = quad.rect.left + (quad.rect.width / 2) + X_OFFSET
      y_start = quad.rect.top
      x, y = probe(quad, x_start, y_start, 0, 1)
      y <= quad.rect.top + (quad.rect.height * TOLERANCE_PCT)
    end

    def detect_bottom(quad)
      x_start = quad.rect.left + (quad.rect.width / 2) + X_OFFSET
      y_start = quad.rect.bottom
      x, y = probe(quad, x_start, y_start, 0, -1)
      y >= quad.rect.bottom - (quad.rect.height * TOLERANCE_PCT)
    end

    def probe(quad, x_start, y_start, x_delta, y_delta)
      x = x_start
      y = y_start

      loop do
        break x, y if COLOR_RANGE.include?(quad.bitmap[x, y])
        x += x_delta
        y += y_delta
      end
    end
  end
end
