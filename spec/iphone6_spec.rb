require 'spec_helper'

include PetDetector

describe 'iPhone 6' do
  def find_entities(image_file, level)
    level = Level.get(level)
    bmp = Bitmap.load(image_file)
    det = BoundaryDetector.new(bmp)
    rect = det.get_bounds
    grid = Grid.new(bmp, rect, level)

    if ENV['DEBUG']
      puts "Top: #{rect.top}, Bottom: #{rect.bottom}, Left: #{rect.left}, Right: #{rect.right}"

      bounds_img = Magick::Image.new(rect.width, rect.height)
      bounds_img.store_pixels(0, 0, rect.width, rect.height, Quadrant.new(bmp, rect).pixels)
      bounds_img.write('quad/rect.jpg')

      grid.quadrants.each_with_index do |row, row_idx|
        row.each_with_index do |quad, col_idx|
          img = Magick::Image.new(quad.rect.width, quad.rect.height)
          img.store_pixels(0, 0, quad.rect.width, quad.rect.height, quad.pixels)
          img.write("quad/#{col_idx}-#{row_idx}.jpg")
        end
      end
    end

    EntityDetector.new(grid, level.animals).entities
  end

  def parse_track_directions(str)
    dirs = str.split(' ')
    %i(top bottom left right).each_with_object({}) do |dir, ret|
      ret[dir] = dirs.include?(dir.to_s)
    end
  end

  let!(:manifest) do
    YAML.load_file(
      File.expand_path('../iphone6/manifest.yml', __FILE__)
    )
  end

  shared_context :check_entities do
    let(:manifest_entry) do
      manifest.find do |entry|
        entry['file'] == image_file
      end
    end

    let(:entity_matrix) do
      find_entities(
        File.expand_path("../iphone6/#{image_file}", __FILE__), level
      )
    end

    it 'detects all entities and track correctly' do
      if ENV['DEBUG']
        results = entity_matrix.flat_map do |x, y, entity|
          "(#{x}, #{y}) #{entity.to_directional_s}"
        end

        puts results.sort.join("\n")
      end

      entity_matrix.each do |col, row, entity|
        expected_quad = manifest_entry['quad'][row][col]
        expected_track = parse_track_directions(expected_quad['track'])

        expect(entity.directions.top).to eq(expected_track[:top]), -> do
          "Expected track at (#{col}, #{row}) to #{expected_track[:top] ? 'have' : 'not have'} a top segment."
        end

        expect(entity.directions.bottom).to eq(expected_track[:bottom]), -> do
          "Expected track at (#{col}, #{row}) to #{expected_track[:bottom] ? 'have' : 'not have'} a bottom segment."
        end

        expect(entity.directions.left).to eq(expected_track[:left]), -> do
          "Expected track at (#{col}, #{row}) to #{expected_track[:left] ? 'have' : 'not have'} a left segment."
        end

        expect(entity.directions.right).to eq(expected_track[:right]), -> do
          "Expected track at (#{col}, #{row}) to #{expected_track[:right] ? 'have' : 'not have'} a right segment."
        end
      end
    end
  end

  describe 'level12' do
    let(:level) { 12 }

    context 'real_deal' do
      let(:image_file) { 'level12/real_deal.jpg' }
      include_context :check_entities
    end

    context 'real_deal2' do
      let(:image_file) { 'level12/real_deal2.jpg' }
      include_context :check_entities
    end

    context 'real_deal3' do
      let(:image_file) { 'level12/real_deal3.jpg' }
      include_context :check_entities
    end

    context 'sim1' do
      let(:image_file) { 'level12/sim1.jpg' }
      include_context :check_entities
    end

    context 'sim2' do
      let(:image_file) { 'level12/sim2.jpg' }
      include_context :check_entities
    end

    context 'sim3' do
      let(:image_file) { 'level12/sim3.jpg' }
      include_context :check_entities
    end

    context 'sim4' do
      let(:image_file) { 'level12/sim4.jpg' }
      include_context :check_entities
    end

    context 'sim5' do
      let(:image_file) { 'level12/sim5.jpg' }
      include_context :check_entities
    end
  end
end
