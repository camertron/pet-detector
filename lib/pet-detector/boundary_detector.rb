module PetDetector
  class BoundaryDetector
    X_OFFSET_FACTOR = 0.15
    Y_OFFSET_FACTOR = 0.15

    BOUNDS_ADJUSTMENT_FACTOR = 0.10
    COLOR_RANGE = ColorRange.new(0..35, 0..35, 0..35)
    PROBE_COUNT = 7

    attr_reader :bitmap

    def initialize(bitmap)
      @bitmap = bitmap
    end

    def get_bounds
      adjust(
        Rect.new(
          probe_left,
          probe_right,
          probe_top,
          probe_bottom
        )
      )
    end

    private

    def adjust(rect)
      # the adjustment factor is calculated as a function of width, then used to
      # adjust both width and height
      adjustment = (rect.width * BOUNDS_ADJUSTMENT_FACTOR).to_i

      Rect.new(
        rect.left - adjustment,
        rect.right + adjustment,
        rect.top - adjustment,
        rect.bottom + adjustment
      )
    end

    def x_offset
      (bitmap.columns * X_OFFSET_FACTOR).round
    end

    def y_offset
      (bitmap.rows * Y_OFFSET_FACTOR).round
    end

    def probe_left
      probe_x(x_offset, 1, y_offset, bitmap.rows - y_offset).compact.min
    end

    def probe_right
      probe_x(bitmap.columns - x_offset, -1, y_offset, bitmap.rows - y_offset).compact.max
    end

    def probe_top
      probe_y(y_offset, 1, x_offset, bitmap.columns - x_offset).compact.min
    end

    def probe_bottom
      probe_y(bitmap.rows - y_offset, -1, x_offset, bitmap.columns - x_offset).compact.max
    end

    def probe_y(y_start, y_delta, x_start, x_stop)
      width = x_stop - x_start
      x_incr = (width / PROBE_COUNT) - ((width / PROBE_COUNT) / 2)
      x_cur = x_start

      PROBE_COUNT.times.map do
        x, y = probe(x_cur, y_start, 0, y_delta)
        x_cur += x_incr
        y
      end
    end

    def probe_x(x_start, x_delta, y_start, y_stop)
      height = y_stop - y_start
      y_incr = (height / PROBE_COUNT) - ((height / PROBE_COUNT) / 2)
      y_cur = y_start

      PROBE_COUNT.times.map do
        x, y = probe(x_start, y_cur, x_delta, 0)
        y_cur += y_incr
        x
      end
    end

    def probe(x_start, y_start, x_delta, y_delta)
      x = x_start
      y = y_start

      loop do
        break nil unless bitmap.in_bounds?(x, y)
        break x, y if COLOR_RANGE.include?(bitmap[x, y])
        x += x_delta
        y += y_delta
      end
    end
  end
end
