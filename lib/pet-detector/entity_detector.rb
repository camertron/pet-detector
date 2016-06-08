module PetDetector
  class Entity
    attr_reader :directions

    def initialize(directions)
      @directions = directions
    end

    def pet?
      false
    end

    def house?
      false
    end

    def car?
      false
    end

    def to_directional_s
      if directions.top? && directions.bottom?
        left = directions.left? ? '-' : ''
        right = directions.right? ? '-' : ''
        "#{left}|#{right}"
      elsif directions.top?
        left = directions.left? ? '_' : ''
        right = directions.right? ? '_' : ''
        "#{left}|#{right}"
      elsif directions.bottom?
        left = directions.left? ? " \u0305" : ''
        right = directions.right? ? " \u0305" : ''
        "#{left}|#{right}"
      else
        left = directions.left? ? '-' : ''
        right = directions.right? ? '-' : ''
        "#{left}#{right}"
      end.rjust(3, ' ')
    end
  end

  class PetEntity < Entity
    attr_reader :name

    def initialize(name, track_directions)
      @name = name
      super(track_directions)
    end

    def pet?
      true
    end

    def to_directional_s
      "#{super} #{to_s}"
    end

    def to_s
      "pet#{name}"
    end
  end

  class HouseEntity < Entity
    attr_reader :name

    def initialize(name, track_directions)
      @name = name
      super(track_directions)
    end

    def house?
      true
    end

    def to_directional_s
      "#{super} #{to_s}"
    end

    def to_s
      "house#{name}"
    end
  end

  class CarEntity < Entity
    def car?
      true
    end

    def to_directional_s
      "#{super} #{to_s}"
    end

    def to_s
      'car'
    end
  end

  class EntityDetector
    attr_reader :grid, :animal_names

    def initialize(grid, animal_names = AnimalDetector::ALL_ANIMALS)
      @grid = grid
      @animal_names = animal_names
    end

    def entities
      ents = grid.map_quadrants do |x, y, quad|
        tracks = track_directions[x, y]

        if car.x == x && car.y == y
          CarEntity.new(tracks)
        elsif animal = animals[x, y]
          if animal.type == 'house'
            HouseEntity.new(animal.name, tracks)
          else
            PetEntity.new(animal.name, tracks)
          end
        else
          Entity.new(tracks)
        end
      end

      EntityMatrix.new(ents)
    end

    private

    def animals
      @animals ||= AnimalDetector.new(grid, animal_names).detect_animals
    end

    def car
      @car ||= CarDetector.new(grid).detect_car
    end

    def track_directions
      @track_directions ||= TrackDetector.new(grid).detect_directions
    end
  end
end
