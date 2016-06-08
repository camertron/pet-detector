require 'spec_helper'

include PetDetector

describe 'iPhone 4' do
  let!(:manifest) do
    YAML.load_file(
      File.expand_path('../iphone4/manifest.yml', __FILE__)
    )
  end

  def find_entities(image_file, level)
    level = Level.get(level)
    bmp = Bitmap.load(image_file)
    det = BoundaryDetector.new(bmp)
    rect = det.get_bounds
    grid = Grid.new(bmp, rect, level)
    EntityDetector.new(grid, level.animals).entities
  end

  def parse_track_directions(str)
    dirs = str.split(' ')
    %i(top bottom left right).each_with_object({}) do |dir, ret|
      ret[dir] = dirs.include?(dir.to_s)
    end
  end

  describe 'level12' do
    it 'sim1' do
      manifest_entry = manifest.find do |entry|
        entry['file'] == 'level12/sim1.png'
      end

      entity_matrix = find_entities(
        File.expand_path('../iphone4/level12/sim1.png', __FILE__), 12
      )

      entity_matrix.each do |col, row, entity|
        expected_quad = manifest_entry['quad'][col][row]
        expected_track = parse_track_directions(expected_quad['track'])

        if entity.directions.top != expected_track[:top]
          puts "Expected track at (#{col}, #{row}) to #{expected_track[:top] ? 'have' : 'not have'} a top segment."
        end

        if entity.directions.bottom != expected_track[:bottom]
          puts "Expected track at (#{col}, #{row}) to #{expected_track[:bottom] ? 'have' : 'not have'} a bottom segment."
        end

        if entity.directions.top != expected_track[:left]
          puts "Expected track at (#{col}, #{row}) to #{expected_track[:left] ? 'have' : 'not have'} a left segment."
        end

        if entity.directions.top != expected_track[:right]
          puts "Expected track at (#{col}, #{row}) to #{expected_track[:right] ? 'have' : 'not have'} a right segment."
        end

        # expect(entity.directions.top).to eq(expected_track[:top]), -> do
        #   "Expected track at (#{col}, #{row}) to #{expected_track[:top] ? 'have' : 'not have'} a top segment."
        # end
      end
    end
  end
end
