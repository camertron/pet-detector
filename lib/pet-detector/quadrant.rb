module PetDetector
  class Quadrant
    attr_reader :bitmap, :rect

    def initialize(bitmap, rect)
      @bitmap = bitmap
      @rect = rect
    end

    def histogram(variance = 1)
      Histogram.new(pixels, variance)
    end

    def pixels
      each_pixel.map { |x, y, pixel| pixel }
    end

    def each_pixel
      return to_enum(__method__) unless block_given?

      rect.each_y.flat_map do |y|
        rect.each_x.map do |x|
          yield x, y, bitmap[x, y]
        end
      end
    end
  end
end
