require 'ruby-prof'
require 'pet-detector'

include PetDetector

result = RubyProf.profile do
  level = Level.get(12)
  bmp = Bitmap.load('./spec/iphone6/level12/real_deal.jpg')
  det = BoundaryDetector.new(bmp)
  rect = det.get_bounds
  grid = Grid.new(bmp, rect, level)
  entities = EntityDetector.new(grid, level.animals).entities
end

# print a graph profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, {})
