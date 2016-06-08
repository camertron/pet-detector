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

    def each_x
      return to_enum(__method__) unless block_given?
      width.times { |i| yield left + i }
    end

    def each_y
      return to_enum(__method__) unless block_given?
      height.times { |i| yield top + i }
    end
  end
end
