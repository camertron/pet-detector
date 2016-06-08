module PetDetector
  class CarScore
    attr_reader :direction, :chi_score, :pixel_score, :x, :y

    def initialize(direction, chi_score, pixel_score, x, y)
      @direction = direction
      @chi_score = chi_score
      @pixel_score = pixel_score
      @x = x
      @y = y
    end
  end

  class CarDetector
    DEFAULT_HIST_VARIANCE = 4.0
    CLEANUP_FILTER = ColorRange.new(0..75, 0..75, 0..75)
    MATCHING_PIXEL_THRESHOLD = 25
    UNFILTERED_PIXEL_THRESHOLD = 0.05
    DIRECTIONS = %w(Up Down Left Right)

    attr_reader :grid, :hist_variance

    def initialize(grid, hist_variance = DEFAULT_HIST_VARIANCE)
      @grid = grid
      @hist_variance = hist_variance
    end

    def detect_car
      calc_scores.compact.min_by(&:chi_score)
    end

    private

    def calc_scores
      grid.each_quadrant.flat_map do |x, y, quad|
        hist = quad
          .histogram(hist_variance)
          .reject_color(CLEANUP_FILTER)

        # don't even bother looking for entities if the majority of pixels were
        # filtered out
        pct = unfiltered_pixel_pct(hist, quad)
        next if pct < UNFILTERED_PIXEL_THRESHOLD

        scores = DIRECTIONS.each_with_object([]) do |direction, ret|
          car_hist = hist_for(car_path_for(direction))
          car_matching_pixels = (hist.buckets.keys & car_hist.buckets.keys).size

          ret << CarScore.new(
            direction, hist.compare(car_hist), car_matching_pixels, x, y
          )
        end

        # remove any scores that have a low number of matching pixels
        scores.reject! { |score| score.pixel_score < MATCHING_PIXEL_THRESHOLD }

        # Choose the entity with the best chi square (smaller is better).
        scores.min_by(&:chi_score)
      end
    end

    def unfiltered_pixel_pct(filtered_hist, quad)
      total = filtered_hist.buckets.inject(0) { |sum, (_, count)| sum + count }
      total / (quad.rect.width * quad.rect.height).to_f
    end

    def car_path_for(direction)
      "/Users/cameron/workspace/Cocos2dGames/Pet Detective/800/car/car#{direction}.png"
    end

    def hist_for(file)
      hist_cache[file] ||= begin
        bmp = Bitmap.load(file)
        rect = Rect.new(0, bmp.columns, 0, bmp.rows)
        quad = Quadrant.new(bmp, rect)
        quad.histogram(hist_variance)
      end
    end

    def hist_cache
      @hist_cache ||= {}
    end
  end
end
