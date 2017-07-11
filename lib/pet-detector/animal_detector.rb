module PetDetector
  class AnimalScore
    attr_reader :name, :type, :chi_score, :pixel_score, :x, :y

    def initialize(name, type, chi_score, pixel_score, x, y)
      @name = name
      @type = type
      @chi_score = chi_score
      @pixel_score = pixel_score
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
      # Choose the entity with the best chi square (smaller is better).
      least_chi_animal = scores.min_by(&:chi_score).name

      # Select all scores with the same entity name as the least chi square
      # entity. This is to be able to later compare the pixel scores of pet and
      # house pairs, since houses almost always have better chi squares than
      # pets but often have fewer matching pixels in their histograms.
      matching = scores.select { |score| score.name == least_chi_animal }

      # Of the scores with the same entity name, find the one with the best
      # pixel match (bigger is better).
      matching.max_by(&:pixel_score)
    end

    def delete_best
      @last_best_match = best_match
      scores.delete(best_match)
    end
  end

  class AnimalDetector
    DEFAULT_HIST_VARIANCE = 3.0
    UNFILTERED_PIXEL_THRESHOLD = 0.05
    MATCHING_PIXEL_THRESHOLD = 0.20 # 25
    CLEANUP_FILTER = ColorRange.new(0..75, 0..75, 0..75)
    ALL_ANIMALS = %w(
      Chameleon Cockatiel Dachsund Ferret Hedgehog
      Husky Pug Rabbit Siamese Tabby Turtle
    )

    attr_reader :grid, :animals, :hist_variance

    def initialize(grid, animals = ALL_ANIMALS, hist_variance = DEFAULT_HIST_VARIANCE)
      @grid = grid
      @hist_variance = hist_variance
      @animals = animals
    end

    def detect_animals
      group_matrix = calc_score_groups
      resolve_collisions(group_matrix)
      group_matrix.map { |x, y, group| group.best_match if group }
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

        hist = quad
          .histogram(hist_variance)
          .reject_color(CLEANUP_FILTER)

        # don't even bother looking for entities if the majority of pixels were
        # filtered out
        pct = unfiltered_pixel_pct(hist, quad)
        next if pct < UNFILTERED_PIXEL_THRESHOLD

        gray = hist.pct_gray
        hist = hist.reject_gray

        scores = animals.each_with_object([]) do |animal, ret|
          entity_hist, type = if gray >= 0.75
            # must be a house if so much gray
            [house_hist_for(animal), 'house']
          else
            [pet_hist_for(animal), 'animal']
          end

          # binding.pry if animal == 'Siamese'

          matching_pixels = matching_pixel_pct(hist, entity_hist)
          ret << AnimalScore.new(animal, type, hist.compare(entity_hist), matching_pixels, x, y)
        end

        # scores = animals.each_with_object([]) do |animal, ret|
        #   house_hist = hist_for(house_path_for(animal))
        #   pet_hist = hist_for(pet_path_for(animal))

        #   house_matching_pixels = (hist.buckets.keys & house_hist.buckets.keys).size
        #   pet_matching_pixels = (hist.buckets.keys & pet_hist.buckets.keys).size

        #   ret << AnimalScore.new(
        #     animal, 'house', hist.compare(house_hist), house_matching_pixels, x, y
        #   )

        #   ret << AnimalScore.new(
        #     animal, 'pet', hist.compare(pet_hist), pet_matching_pixels, x, y
        #   )
        # end

        # remove any scores that have a low number of matching pixels
        scores.reject! { |score| score.pixel_score < MATCHING_PIXEL_THRESHOLD }
        # binding.pry
        scores.size == 0 ? nil : AnimalScoreGroup.new(scores)
      end

      Matrix.new(quadrants)
    end

    def matching_pixel_pct(hist1, hist2)
      hist1_count = 0.0
      hist2_count = 0.0

      intersecting_pixels = hist1.buckets.keys & hist2.buckets.keys
      return 0.0 if intersecting_pixels.size == 0

      intersecting_pixels.each do |pixel_arr|
        hist1_count += hist1.buckets[pixel_arr]
        hist2_count += hist2.buckets[pixel_arr]
      end

      return hist1_count / hist2_count if hist2_count > hist1_count
      hist2_count / hist1_count
    end

    # resolves the cases where the same animal/house was chosen for multiple grid
    # quadrants
    def resolve_collisions(group_matrix)
      loop do
        # put best matches into buckets
        collisions = group_matrix.each_with_object({}) do |(x, y, group), ret|
          next unless group
          match = group.best_match
          key = "#{match.type}#{match.name}"
          ret[key] ||= []
          ret[key] << group
        end

        # ignore any bucket that only has one pet/house, since that doesn't
        # indicate a collision at all
        collisions.reject! { |k, v| v.size < 2 }

        break if collisions.empty?

        # of the matches in the collision, choose the best one and delete the
        # other bests from their score group - in other words, pick the second
        # best in all the inferior groups
        collisions.each_pair do |animal, collision|
          best_group = collision.min_by { |group| group.best_match.chi_score }

          collision.each do |group|
            unless group == best_group
              group.delete_best
            end
          end
        end
      end

      group_matrix
    end

    def unfiltered_pixel_pct(filtered_hist, quad)
      total = filtered_hist.buckets.inject(0) { |sum, (_, count)| sum + count }
      total / (quad.rect.width * quad.rect.height).to_f
    end

    def house_path_for(animal)
      "/Users/cameron/workspace/Cocos2dGames/Pet Detective/640/interests/house#{animal}House.png"
    end

    def pet_path_for(animal)
      "/Users/cameron/workspace/Cocos2dGames/Pet Detective/640/interests/pet#{animal}.png"
    end

    def pet_hist_for(animal)
      hist_for(pet_path_for(animal))
    end

    def house_hist_for(animal)
      hist_for(house_path_for(animal))
    end

    def hist_for(file)
      hist_cache[file] ||= begin
        bmp = Bitmap.load(file)
        rect = Rect.new(0, bmp.columns, 0, bmp.rows)
        quad = Quadrant.new(bmp, rect)

        # calculate histogram and remove all gray pixels
        quad.histogram(hist_variance).reject_gray
      end
    end

    def hist_cache
      self.class.hist_cache
    end

    def self.hist_cache
      @hist_cache ||= {}
    end
  end
end
