class BoundaryDetector
  X_OFFSET = 90
  Y_OFFSET = 230
  COLOR_RANGE = ColorRange.new(0..40, 0..40, 0..40)
  PROBE_COUNT = 4

  attr_reader :bitmap

  def initialize(bitmap)
    @bitmap = bitmap
  end

  def get_bounds
    Rect.new(
      probe_left,
      probe_right,
      probe_top,
      probe_bottom
    )
  end

  private

  def probe_left
    probe_x(X_OFFSET, 1).compact.min
  end

  def probe_right
    probe_x(bitmap.columns - X_OFFSET, -1).compact.max
  end

  def probe_top
    probe_y(Y_OFFSET, 1).compact.min
  end

  def probe_bottom
    probe_y(bitmap.rows - Y_OFFSET, -1).compact.max
  end

  def probe_y(y_start, y_delta)
    x_incr = (bitmap.columns / PROBE_COUNT) - ((bitmap.columns / PROBE_COUNT) / 2)
    x_start = x_incr

    PROBE_COUNT.times.map do
      x, y = probe(x_start, y_start, 0, y_delta)
      x_start += x_incr
      y
    end
  end

  def probe_x(x_start, x_delta)
    y_incr = (bitmap.rows / PROBE_COUNT) - ((bitmap.rows / PROBE_COUNT) / 2)
    y_start = y_incr

    PROBE_COUNT.times.map do
      x, y = probe(x_start, y_start, x_delta, 0)
      y_start += y_incr
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
