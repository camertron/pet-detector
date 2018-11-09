require 'phashion'

module PetDetector
  class AnimalScore
    attr_reader :name, :type, :distance, :x, :y

    def initialize(name, type, distance, x, y)
      @name = name
      @type = type
      @distance = distance
      @x = x
      @y = y
    end
  end

  class AnimalScoreGroup
    attr_reader :scores

    def initialize(scores)
      @scores = scores
    end

    def best_match
      scores.min_by(&:distance)
    end
  end

  class AnimalDetector
    UNFILTERED_PIXEL_THRESHOLD = 0.05
    GRAY_HOUSE_PERCENTAGE = 0.65
    MAX_HAMMING_DISTANCE = 15
    CLEANUP_FILTER = ColorRange.new(0..75, 0..75, 0..75)
    ALL_ANIMALS = %w(
      Chameleon Cockatiel Dachsund Ferret Hedgehog
      Husky Pug Rabbit Siamese Tabby Turtle
    )

    attr_reader :grid, :car, :animals

    def initialize(grid, car, animals = ALL_ANIMALS)
      @grid = grid
      @car = car
      @animals = animals
    end

    def detect_animals
      calc_score_groups.map { |x, y, group| group.best_match if group }
    end

    private

    def calc_score_groups
      quadrants = grid.map_quadrants do |x, y, quad|
        # trim off 16% from the bottom, which can include the top of another house
        quad = Quadrant.new(
          quad.bitmap, Rect.new(
            quad.rect.left,
            quad.rect.right,
            quad.rect.top,
            quad.rect.bottom - (quad.rect.height * 0.16).round
          )
        )

        # if the car is to our right, it can often stick its butt in our
        # face and mess up the trim and therefore the phash matching
        if car_on_right?(x, y)
          quad.rect.right -= (quad.rect.width * 0.16).round
        end

        hist = quad.histogram.reject_color(CLEANUP_FILTER)
        gray = hist.pct_gray

        Bitmap.new(nil, quad.pixels, quad.rect.width, quad.rect.height)
          .reject_gray
          .trim
          .save('./tmp/quad.jpg')

        quad_phashion = Phashion::Image.new('./tmp/quad.jpg')

        scores = if gray < 0.9
          animals.each_with_object([]) do |animal, ret|
            entity_phashion, type = if gray >= GRAY_HOUSE_PERCENTAGE
              [house_phashion_for(animal), 'house']
            else
              [pet_phashion_for(animal), 'animal']
            end

            distance = quad_phashion.distance_from(entity_phashion)
            ret << AnimalScore.new(animal, type, distance, x, y)
          end
        else
          []
        end

        if !car_on_right?(x, y)
          scores.reject! { |s| s.distance > MAX_HAMMING_DISTANCE }
        end

        scores.size == 0 ? nil : AnimalScoreGroup.new(scores)
      end

      Matrix.new(quadrants)
    end

    def car_on_right?(x, y)
      car.x == x + 1 && car.y == y
    end

    def house_path_for(animal)
      File.join(PetDetector.resources_dir, 'entities', "house#{animal}House.png")
    end

    def pet_path_for(animal)
      File.join(PetDetector.resources_dir, 'entities', "pet#{animal}.png")
    end

    def pet_phashion_for(animal)
      path = pet_path_for(animal)

      self.class.phashion_cache[path] ||= begin
        mod_path = "./tmp/#{animal}_pet_mod.jpg"
        Bitmap.load(path).reject_gray.trim.save(mod_path)
        Phashion::Image.new(mod_path)
      end
    end

    def house_phashion_for(animal)
      path = house_path_for(animal)

      self.class.phashion_cache[path] ||= begin
        mod_path = "./tmp/#{animal}_house_mod.jpg"
        Bitmap.load(path).reject_gray.trim.save(mod_path)
        Phashion::Image.new(mod_path)
      end
    end

    def self.phashion_cache
      @phashion_cache ||= {}
    end
  end
end
