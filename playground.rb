require 'pry-byebug'
require 'benchmark'

autoload :AnimalDetector,   './lib/animal_detector'
autoload :Bitmap,           './lib/bitmap'
autoload :BoundaryDetector, './lib/boundary_detector'
autoload :CarDetector,      './lib/car_detector'
autoload :ColorRange,       './lib/color_range'
autoload :EntityDetector,   './lib/entity_detector'
autoload :EntityMatrix,     './lib/entity_matrix'
autoload :Grid,             './lib/grid'
autoload :Histogram,        './lib/histogram'
autoload :Matrix,           './lib/matrix'
autoload :Quadrant,         './lib/quadrant'
autoload :Rect,             './lib/rect'
autoload :Solver,           './lib/solver'
autoload :TrackDetector,    './lib/track_detector'

bmp = Bitmap.load('./real_deal2.jpg')
# bmp = Bitmap.load('./IMG_1468.jpg')  # quad
# bmp = Bitmap.load('./IMG_1471.jpg')  # quad2
# bmp = Bitmap.load('./IMG_1474.jpg')  # quad3
# bmp = Bitmap.load('./IMG_1475.jpg')  # quad4
det = BoundaryDetector.new(bmp)
rect = det.get_bounds

# widen/lengthen bounds to make room for edge quadrants
rect.left -= 52
rect.right += 52
rect.top -= 52
rect.bottom += 52

grid = Grid.new(bmp, rect)

# grid.quadrants.each_with_index do |row, row_idx|
#   row.each_with_index do |quad, col_idx|
#     img = Magick::Image.new(quad.rect.width, quad.rect.height)
#     img.store_pixels(0, 0, quad.rect.width, quad.rect.height, quad.pixels)
#     img.write("/Users/cameron/workspace/pet/quad4/#{col_idx}-#{row_idx}.jpg")
#   end
# end

animals = %w(Cockatiel Dachsund Hedgehog Husky Siamese Tabby Turtle)
entity_matrix = EntityDetector.new(grid, animals).entities
# distance_map = entity_matrix.to_distance_map

# results = entity_matrix.flat_map do |x, y, entity|
#   "(#{x}, #{y}) #{entity}"
# end

# puts results.sort.join("\n")

solver = Solver.new(entity_matrix, 25)
puts "Started..."
result = nil
puts(Benchmark.measure do
  result = solver.solve
end)

puts result.map { |e| "#{e.pet? ? 'pet' : 'house'}#{e.name}" }.join("\n")

exit 0

track_detector = TrackDetector.new(grid)
directions = track_detector.detect_directions
binding.pry

exit 0

car_detector = CarDetector.new(grid)
result = car_detector.detect_car
puts result.inspect

exit 0

animals = %w(Cockatiel Dachsund Hedgehog Husky Siamese Tabby Turtle)
animal_detector = AnimalDetector.new(grid, animals)
groups = animal_detector.detect_animals
matches = groups.compact.map { |g| g.best_match }

expected = {
  # quad
  '0-1' => 'houseSiamese',
  '0-2' => 'houseHedgehog',
  '0-4' => 'petTabby',
  '1-2' => 'houseHusky',
  '1-5' => 'houseDachsund',
  '2-0' => 'petDachsund',
  '2-1' => 'houseCockatiel',
  '2-2' => 'petHusky',
  '2-4' => 'petSiamese',
  '2-5' => 'petCockatiel',
  '3-1' => 'petHedgehog',
  '3-3' => 'houseTurtle',
  '3-4' => 'petTurtle',
  '3-5' => 'houseTabby'

  # quad2
  # '0-3' => 'houseHusky',
  # '0-4' => 'houseCockatiel',
  # '0-5' => 'houseTurtle',
  # '1-0' => 'petHedgehog',
  # '1-1' => 'houseHedgehog',
  # '1-5' => 'petTurtle',
  # '2-1' => 'petSiamese',
  # '2-2' => 'houseSiamese',
  # '2-3' => 'petDachsund',
  # '2-4' => 'petCockatiel',
  # '2-5' => 'petTabby',
  # '3-0' => 'houseTabby',
  # '3-2' => 'houseDachsund',
  # '3-4' => 'petHusky'
}

matches.each do |match|
  coords = "#{match.x}-#{match.y}"
  puts "#{coords}: #{match.type}#{match.entity}/#{expected[coords]} (#{match.pixel_score})"
end

# collisions = groups.each_with_object({}) do |group, ret|
#   next unless group
#   match = group.best_match
#   key = "#{match.type}#{match.entity}"
#   ret[key] ||= []
#   ret[key] << group
# end

# collisions.reject! { |k, v| v.size < 2 }

# binding.pry
# puts 'foo'

# result = dog_hist.buckets.inject(0.0) do |sum, (pixel, expected_frequency)|
#   next sum unless hist.buckets.include?(pixel)
#   observed_frequency = (hist.buckets[pixel] || 0).to_f
#   ((observed_frequency - expected_frequency) ** 2) / (expected_frequency + observed_frequency)
# end

# quad = grid[5, 1]
# img = Magick::Image.new(quad.rect.width, quad.rect.height)
# grays = ColorRange.new(0..75, 0..75, 0..75)
# transparent_pixel = Magick::Pixel.new(65535, 65535, 65535, 65535)
# pixels = quad.each_pixel.map do |x, y, pixel|
#   if grays.include?(pixel)
#     transparent_pixel
#   else
#     pixel
#   end
# end
# img.store_pixels(0, 0, quad.rect.width, quad.rect.height, pixels)
# img.write("/Users/cameron/workspace/pet/filtered_doghouse.jpg")

# grid.quadrants.each_with_index do |row, row_idx|
#   row.each_with_index do |quad, col_idx|
#     img = Magick::Image.new(quad.rect.width, quad.rect.height)
#     img.store_pixels(0, 0, quad.rect.width, quad.rect.height, quad.pixels)
#     img.write("/Users/cameron/workspace/pet/quad/#{col_idx}-#{row_idx}.jpg")
#   end
# end

# hist = grid[2, 0].histogram

# def hit?(pixel)
#   (0..70).include?(pixel.red & 255) &&
#     (0..70).include?(pixel.green & 255) &&
#     (0..70).include?(pixel.blue & 255)
# end

# filtered_hist = hist.each_with_object({}) do |(pixel, count), ret|
#   ret[pixel] = count unless hit?(pixel)
# end
