module PetDetector
  class Rect
    attr_accessor :left, :right, :top, :bottom

    def initialize(left, right, top, bottom)
      @left = left
      @right = right
      @top = top
      @bottom = bottom
    end

    def width
      right - left
    end

    def height
      bottom - top
    end

    def ==(other)
      left == other.left &&
        right == other.right &&
        top == other.top &&
        bottom == other.bottom
    end

    def each_x
      return to_enum(__method__) unless block_given?
      width.times { |i| yield left + i }
    end

    def each_y
      return to_enum(__method__) unless block_given?
      height.times { |i| yield top + i }
    end

    def to_a
      [left, right, top, bottom]
    end
  end
end
