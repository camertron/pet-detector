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
    CLEANUP_FILTER = ColorRange.new(0..75, 0..75, 0..75)
    ALL_ANIMALS = %w(
      Chameleon Cockatiel Dachsund Ferret Hedgehog
      Husky Pug Rabbit Siamese Tabby Turtle
    )

    attr_reader :grid, :animals

    def initialize(grid, animals = ALL_ANIMALS)
      @grid = grid
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

        hist = quad.histogram.reject_color(CLEANUP_FILTER)
        gray = hist.pct_gray

        Bitmap.new(nil, quad.pixels, quad.rect.width, quad.rect.height)
          .reject_gray
          .trim
          .save('./tmp/quad.jpg')

        quad_phashion = Phashion::Image.new('./tmp/quad.jpg')

        scores = animals.each_with_object([]) do |animal, ret|
          entity_phashion, type = if gray >= 0.65
            [house_phashion_for(animal), 'house']
          else
            [pet_phashion_for(animal), 'animal']
          end

          distance = quad_phashion.distance_from(entity_phashion)
          ret << AnimalScore.new(animal, type, distance, x, y)
        end

        scores.reject! { |s| s.distance > 15 }
        scores.size == 0 ? nil : AnimalScoreGroup.new(scores)
      end

      Matrix.new(quadrants)
    end

    def house_path_for(animal)
      "/Users/cameron/workspace/Cocos2dGames/Pet Detective/800/interests/house#{animal}House.png"
    end

    def pet_path_for(animal)
      "/Users/cameron/workspace/Cocos2dGames/Pet Detective/800/interests/pet#{animal}.png"
    end

    # def pet_phashion_for(animal)
    #   phashion_for(pet_path_for(animal))
    # end

    # def house_phashion_for(animal)
    #   phashion_for(house_path_for(animal))
    # end

    # def phashion_for(path)
    #   self.class.phashion_cache[path] ||= begin
    #     ext = File.extname(path)
    #     filename = File.basename(path).chomp(ext)
    #     mod_path = "./tmp/#{filename}_mod#{ext}"
    #     Bitmap.load(path).reject_gray.trim.save(mod_path)
    #     Phashion::Image.new(mod_path)
    #   end
    # end

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
