require 'plist'
require 'rmagick'
require 'pry-byebug'

image = Magick::Image.read('/Users/cameron/workspace/Cocos2dGames/Pet Detective/800/roads.png').first
frames = Plist.parse_xml('/Users/cameron/workspace/Cocos2dGames/Pet Detective/800/roads.plist')['frames']

frames.each_pair do |filename, frame_data|
  # eg. {{2,2},{250,250}}
  bounds = frame_data['frame'][1..-2]
    .split('},{')
    .map { |f| f.gsub(/[\{\}]/, '') }
    .map { |f| f.split(',').map(&:to_i) }

  x1, y1 = bounds.first
  x2, y2 = bounds.last
  width = x2 - x1
  height = y2 - y1

  road = image.crop(x1, y1, width, height)
  road.write("./road/#{filename}")
  road.destroy!
end
