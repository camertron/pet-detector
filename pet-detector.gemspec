$:.unshift File.join(File.dirname(__FILE__), 'lib')

Gem::Specification.new do |s|
  s.name     = 'pet-detector'
  s.version  = '1.0'
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'https://github.com/camertron/pet-detector'

  s.description = s.summary = "Automatic solver for Lumosity's Pet Detective game."

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true

  s.add_dependency 'rmagick', '~> 2.0'
  s.add_dependency 'simple-graph', '~> 1.0'

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'pet-detector.gemspec']
end
