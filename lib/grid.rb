class Grid
  QUADRANT_DIM = 156
  QUADRANT_DIM_F = QUADRANT_DIM.to_f

  attr_reader :bitmap, :quadrants

  def initialize(bitmap, rect)
    @bitmap = bitmap

    width = (rect.width / QUADRANT_DIM_F).round
    height = (rect.height / QUADRANT_DIM_F).round

    cur_y = rect.top

    @quadrants = height.times.map do
      cur_x = rect.left

      row = width.times.map do
        quadrant = Quadrant.new(
          bitmap, Rect.new(
            cur_x, cur_x + QUADRANT_DIM, cur_y, cur_y + QUADRANT_DIM
          )
        )

        cur_x += QUADRANT_DIM
        quadrant
      end

      cur_y += QUADRANT_DIM
      row
    end
  end

  def [](x, y)
    quadrants[y][x]
  end

  def each_quadrant
    return to_enum(__method__) unless block_given?
    quadrants.each_with_index do |row, row_idx|
      row.each_with_index do |quadrant, col_idx|
        yield col_idx, row_idx, quadrant
      end
    end
  end

  def map_quadrants
    return to_enum(__method__) unless block_given?
    quadrants.each_with_index.map do |row, row_idx|
      row.each_with_index.map do |quadrant, col_idx|
        yield col_idx, row_idx, quadrant
      end
    end
  end
end
