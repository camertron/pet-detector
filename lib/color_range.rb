class ColorRange
  attr_reader :r_range, :g_range, :b_range

  def initialize(r_range, g_range, b_range)
    @r_range = r_range
    @g_range = g_range
    @b_range = b_range
  end

  def include?(pixel)
    r_range.include?(pixel.red & 255) &&
      g_range.include?(pixel.green & 255) &&
      b_range.include?(pixel.blue & 255)
  end
end
