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
    GAS_OVERLAY_COLOR_RANGE = ColorRange.new(111..116, 111..116, 111..116)

    # an offset to shift the x probe slightly to the right so the blacker
    # left-hand side of the rooves of houses don't interfere
    X_OFFSET = 10

    # track must exist within this percentage of the left, right, top, and bottom
    # quadrant boundaries
    TOLERANCE_PCT = 0.15

    attr_reader :grid, :car

    def initialize(grid, car)
      @grid = grid
      @car = car
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
            detect_top(quad, x, y), detect_bottom(quad, x, y),
            detect_left(quad, x, y), detect_right(quad, x, y),
            x, y
          )
        end
      )

      matrix.each do |x, y, item|
        item.matrix = matrix
      end

      matrix
    end

    def detect_left(quad, quad_x, quad_y)
      x_start = quad.rect.left
      y_start = quad.rect.top + (quad.rect.height / 2)
      x, y = probe(quad, x_start, y_start, 1, 0, quad_x, quad_y)
      return false if !x || !y
      x <= quad.rect.left + (quad.rect.width * TOLERANCE_PCT)
    end

    def detect_right(quad, quad_x, quad_y)
      x_start = quad.rect.right
      y_start = quad.rect.top + (quad.rect.height / 2)
      x, y = probe(quad, x_start, y_start, -1, 0, quad_x, quad_y)
      return false if !x || !y
      x >= quad.rect.right - (quad.rect.width * TOLERANCE_PCT)
    end

    def detect_top(quad, quad_x, quad_y)
      x_start = quad.rect.left + (quad.rect.width / 2) + X_OFFSET
      y_start = quad.rect.top
      x, y = probe(quad, x_start, y_start, 0, 1, quad_x, quad_y)
      return false if !x || !y
      y <= quad.rect.top + (quad.rect.height * TOLERANCE_PCT)
    end

    def detect_bottom(quad, quad_x, quad_y)
      x_start = quad.rect.left + (quad.rect.width / 2) + X_OFFSET
      y_start = quad.rect.bottom
      x, y = probe(quad, x_start, y_start, 0, -1, quad_x, quad_y)
      return false if !x || !y
      y >= quad.rect.bottom - (quad.rect.height * TOLERANCE_PCT)
    end

    def probe(quad, x_start, y_start, x_delta, y_delta, quad_x, quad_y)
      x = x_start
      y = y_start

      loop do
        # color encountered
        break x, y if COLOR_RANGE.include?(quad.bitmap[x, y])

        if car.x == quad_x && car.y == quad_y
          if GAS_OVERLAY_COLOR_RANGE.include?(quad.bitmap[x, y])
            break x, y
          end
        end

        x += x_delta
        y += y_delta

        # outside bounds of quad
        if x > x_start + quad.rect.width || y > y_start + quad.rect.height
          break [nil, nil]
        end
      end
    end
  end
end
