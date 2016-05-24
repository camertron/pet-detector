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
det = BoundaryDetector.new(bmp)

STDOUT.write('Detecting grid boundaries... ')
rect = det.get_bounds
puts 'done'

# widen/lengthen bounds to make room for edge quadrants
rect.left -= 52
rect.right += 52
rect.top -= 52
rect.bottom += 52

grid = Grid.new(bmp, rect)

animal_names = %w(Cockatiel Dachsund Hedgehog Husky Siamese Tabby Turtle)
STDOUT.write('Detecting entities... ')
entity_matrix = EntityDetector.new(grid, animal_names).entities
puts 'done'

STDOUT.write('Attempting to solve... ')
solver = Solver.new(entity_matrix, 25)
solution = solver.solve
puts 'done'

puts "\nOk, give this a try:"
puts ''

solution.each_with_index do |entity, idx|
  puts "#{idx + 1}. #{entity.to_s}"
end
