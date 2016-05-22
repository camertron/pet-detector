require 'rmagick'

class Bitmap
  def self.load(path)
    image = Magick::Image.read(path).first

    new(
      image.get_pixels(0, 0, image.columns, image.rows),
      image.columns, image.rows
    )
  end

  attr_reader :pixels, :columns, :rows

  def initialize(pixels, columns, rows)
    @pixels = pixels
    @columns = columns
    @rows = rows
  end

  def [](x, y)
    pixels[(y * columns) + x]
  end

  def in_bounds?(x, y)
    x < columns && y < rows
  end
end
