require 'graphics'
require 'pry-byebug'

module PetDetector
  class TrackBody < Graphics::Body
    COUNT = 1
    SCALE_FACTOR = 0.5
    TRACK_MAP = {
      # top bottom left right
      0b1000 => 'road_01_EndDown.png',
      0b0001 => 'road_02_EndLeft.png',
      0b1001 => 'road_03_CornerBottomLeft.png',
      0b0100 => 'road_04_EndUp.png',
      0b1100 => 'road_05_ThroughVertical.png',
      0b0101 => 'road_06_CornerTopLeft.png',
      0b1101 => 'road_07_3WayRight.png',
      0b0010 => 'road_08_EndRight.png',
      0b1010 => 'road_09_CornerBottomRight.png',
      0b0011 => 'road_10_ThroughHorizontal.png',
      0b1011 => 'road_11_3WayUp.png',
      0b0110 => 'road_12_CornerTopRight.png',
      0b1110 => 'road_13_3WayLeft.png',
      0b0111 => 'road_14_3WayDown.png',
      0b1111 => 'road_15_4Way.png'
    }

    attr_reader :w, :entity

    def initialize(w, entity, col_idx, row_idx)
      @w = w
      @entity = entity
      self.x = col_idx * (Simulation::QUAD_WIDTH * SCALE_FACTOR)
      self.y = w.h - ((row_idx + 1) * (Simulation::QUAD_HEIGHT * SCALE_FACTOR)) - w.y_offset
    end

    def image
      @image ||= w.image(
        File.expand_path(
          File.join('..', '..', 'resources', 'road', TRACK_MAP[entity.directions.to_i]), __dir__
        )
      )
    end

    def draw
      w.put image, x, y, 0, SCALE_FACTOR, SCALE_FACTOR
    end
  end

  class EntityBody < Graphics::Body
    COUNT = 1
    SCALE_FACTOR = 0.65

    attr_reader :w, :entity

    def initialize(w, entity, track_body)
      @w = w
      @entity = entity
      self.x = track_body.x + (((Simulation::QUAD_WIDTH * TrackBody::SCALE_FACTOR) / 2) - ((image.w * SCALE_FACTOR) / 2))
      self.y = track_body.y + image.h * SCALE_FACTOR
    end

    def draw
      w.put image, x, y, 0, SCALE_FACTOR, SCALE_FACTOR
    end
  end

  class AnimalHouseBody < EntityBody
    def initialize(*args)
      super *args
      @visited = false
    end

    def image
      @image ||= begin
        basename = if entity.pet?
          "pet#{entity.name}.png"
        else entity.house?
          "house#{entity.name}House.png"
        end

        w.image(File.join(PetDetector.resources_dir, 'entities', basename))
      end
    end

    def visit!
      @visited = true
    end

    def draw
      super unless @visited
    end
  end

  class CarBody < EntityBody
    def image
      case a
      when Simulation::UP
        up_image
      when Simulation::DOWN
        down_image
      when Simulation::LEFT
        left_image
      else
        right_image
      end
    end

    private

    def up_image
      @up_image ||= w.image(
        File.join(PetDetector.resources_dir, 'entities', 'carUp.png')
      )
    end

    def down_image
      @down_image ||= w.image(
        File.join(PetDetector.resources_dir, 'entities', 'carDown.png')
      )
    end

    def left_image
      @left_image ||= w.image(
        File.join(PetDetector.resources_dir, 'entities', 'carLeft.png')
      )
    end

    def right_image
      @right_image ||= w.image(
        File.join(PetDetector.resources_dir, 'entities', 'carRight.png')
      )
    end
  end

  class Simulation < Graphics::Simulation
    QUAD_HEIGHT = 250
    QUAD_WIDTH = 250
    UP = 90
    DOWN = 270
    LEFT = 180
    RIGHT = 0

    attr_reader :level, :entity_matrix, :solution
    attr_reader :y_offset

    def initialize(level, entity_matrix, solution)
      width = (QUAD_WIDTH * TrackBody::SCALE_FACTOR) * level.width
      height = (QUAD_HEIGHT * TrackBody::SCALE_FACTOR) * level.height
      @y_offset = QUAD_HEIGHT - (QUAD_HEIGHT * TrackBody::SCALE_FACTOR)

      super width, height

      @level = level
      @entity_matrix = entity_matrix
      @solution = solution

      @entity_bodies = {}
      car_entity = nil
      car_track_body = nil

      @track_bodies = entity_matrix.map do |col_idx, row_idx, entity|
        track_body = TrackBody.new(self, entity, col_idx, row_idx)

        if entity.pet? || entity.house? || entity.car?
          if entity.car?
            car_entity = entity
            car_track_body = track_body
          else
            @entity_bodies[entity.to_s] = AnimalHouseBody.new(self, entity, track_body)
          end
        end

        track_body
      end

      # create the car last so it will be on top of all the other entities
      @entity_bodies[car_entity.to_s] = CarBody.new(self, car_entity, car_track_body)

      @quad_x = car.entity.x
      @quad_y = car.entity.y
      @instr_idx = 1

      car.m = 3

      if target[1] > car.entity.x
        car.a = RIGHT
      elsif target[1] < car.entity.x
        car.a = LEFT
      elsif target[2] > car.entity.y
        car.a = DOWN
      else
        car.a = UP
      end
    end

    def draw(n)
      clear

      put bg, 0, h - h * (bg.h / h), 0, w / bg.w, h / bg.h

      @track_bodies.each { |_, _, ent| ent.draw }
      @entity_bodies.values.each(&:draw)

      if @instr_idx >= instructions.size
        put success, (w / 2) - (success.w * 0.5 / 2), (h / 2) - (success.h * 0.5 / 2), 0, 0.5, 0.5
      end
    end

    def update(n)
      if arrived?
        old_target = target
        @instr_idx += 1

        if target[0] == :visit
          @entity_bodies[target[1]].visit!
          @instr_idx += 1
        end

        if @instr_idx >= instructions.size
          self.paused = true
          return
        end

        if target[1] > old_target[1]
          car.a = RIGHT
        elsif target[1] < old_target[1]
          car.a = LEFT
        elsif target[2] > old_target[2]
          car.a = DOWN
        else
          car.a = UP
        end
      else
        car.move
      end
    end

    private

    def instructions
      @instructions ||= ([car.entity] + solution).each_cons(2).flat_map do |from_entity, to_entity|
        sub_path = entity_matrix.graph.shortest_path(from_entity, to_entity)[1..-1].map do |ent|
          [:move, ent.x, ent.y]
        end

        if to_entity.pet? || to_entity.house?
          sub_path << [:visit, to_entity.to_s]
        end

        sub_path
      end
    end

    def arrived?
      case car.a
      when UP
        car.y >= target_body.y + (target_body.image.h / 2) #- (car.image.h / 2)
      when LEFT
        car.x <= target_body.x + (target_body.image.w / 2) - (car.image.w / 2)
      when DOWN
        car.y <= target_body.y + (target_body.image.h / 2) #- (car.image.h / 2)
      when RIGHT
        car.x >= target_body.x + (target_body.image.w / 2) - (car.image.w / 2) - 20
      end
    end

    def target
      instructions[@instr_idx]
    end

    def target_body
      @track_bodies[target[1], target[2]]
    end

    def car
      @car ||= @entity_bodies['car']
    end

    def bg
      @bg ||= image(
        File.expand_path(File.join(PetDetector.resources_dir, 'background.jpg'), __dir__)
      )
    end

    def success
      @success ||= image(
        File.expand_path(File.join(PetDetector.resources_dir, 'success.png'), __dir__)
      )
    end
  end
end
