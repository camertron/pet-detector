class Matrix
  include Enumerable

  attr_reader :rows

  def initialize(rows)
    @rows = rows
  end

  def [](x, y)
    rows[y][x]
  end

  def width
    rows.first.size
  end

  def height
    rows.size
  end

  def each
    return to_enum(__method__) unless block_given?

    rows.each_with_index do |row, row_idx|
      row.each_with_index do |item, col_idx|
        yield col_idx, row_idx, item
      end
    end
  end

  def map
    return to_enum(__method__) unless block_given?

    self.class.new(
      rows.each_with_index.map do |row, row_idx|
        row.each_with_index.map do |item, col_idx|
          yield col_idx, row_idx, item
        end
      end
    )
  end

  def flat_map
    return to_enum(__method__) unless block_given?

    rows.each_with_index.flat_map do |row, row_idx|
      row.each_with_index.map do |item, col_idx|
        yield col_idx, row_idx, item
      end
    end
  end

  def to_a
    rows
  end
end
