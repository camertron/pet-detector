module PetDetector
  class Grid
    attr_reader :bitmap, :rect, :level, :quadrants

    def initialize(bitmap, rect, level)
      @bitmap = bitmap
      @rect = rect
      @level = level

      unit_width = (rect.width / level.width.to_f).round
      unit_height = (rect.height / level.height.to_f).round

      cur_y = rect.top

      @quadrants = level.height.times.map do
        cur_x = rect.left

        row = level.width.times.map do
          quadrant = Quadrant.new(
            bitmap, Rect.new(
              cur_x, cur_x + unit_width, cur_y, cur_y + unit_height
            )
          )

          cur_x += unit_width
          quadrant
        end

        cur_y += unit_height
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
end
