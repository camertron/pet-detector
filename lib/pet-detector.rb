module PetDetector
  autoload :AnimalDetector,   'pet-detector/animal_detector'
  autoload :Bitmap,           'pet-detector/bitmap'
  autoload :BoundaryDetector, 'pet-detector/boundary_detector'
  autoload :CarDetector,      'pet-detector/car_detector'
  autoload :ColorRange,       'pet-detector/color_range'
  autoload :EntityDetector,   'pet-detector/entity_detector'
  autoload :EntityMatrix,     'pet-detector/entity_matrix'
  autoload :GASolver,         'pet-detector/ga_solver'
  autoload :GraphSolver,      'pet-detector/graph_solver'
  autoload :Grid,             'pet-detector/grid'
  autoload :Histogram,        'pet-detector/histogram'
  autoload :Level,            'pet-detector/level'
  autoload :Matrix,           'pet-detector/matrix'
  autoload :Quadrant,         'pet-detector/quadrant'
  autoload :Rect,             'pet-detector/rect'
  autoload :Simulation,       'pet-detector/simulation'
  autoload :TrackDetector,    'pet-detector/track_detector'

  Solver = GraphSolver

  def self.resources_dir
    @resources_dir ||= File.expand_path('../../resources', __FILE__)
  end
end
