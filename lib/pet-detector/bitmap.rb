require 'rmagick'

module PetDetector
  class Bitmap
    WHITE = Magick::Pixel.new(255 * 255, 255 * 255, 255 * 255)

    def self.load(path)
      image = Magick::Image.read(path).first

      new(
        path,
        image.get_pixels(0, 0, image.columns, image.rows),
        image.columns, image.rows
      )
    end

    attr_reader :filename, :pixels, :columns, :rows

    def initialize(filename, pixels, columns, rows)
      @filename = filename
      @pixels = pixels
      @columns = columns
      @rows = rows
    end

    def [](x, y)
      pixels[(y * columns) + x]
    end

    def in_bounds?(x, y)
      (x >= 0 && x < columns) && (y >= 0 && y < rows)
    end

    def reject
      new_pixels = pixels.map do |pixel|
        if yield(pixel)
          WHITE
        else
          pixel
        end
      end

      Bitmap.new(filename, new_pixels, columns, rows)
    end

    def reject_color(color_range)
      reject { |px| color_range.include?(px) }
    end

    def reject_gray
      reject { |px| px.red == px.green && px.green == px.blue }
      # reject do |px|
        # r = px.red & 255
        # g = px.green & 255
        # b = px.blue & 255

        # ((r - g).abs + (r - b).abs + (g - b).abs) / 3 < 15

        # ((px.red & 255) - (px.green & 255)).abs < 12 && ((px.green & 255) - (px.blue & 255)).abs < 12
      # end
    end

    def trim
      image = Magick::Image.new(columns, rows)
      image.store_pixels(0, 0, columns, rows, pixels)
      image = image.trim

      self.class.new(
        filename,
        image.get_pixels(0, 0, image.columns, image.rows),
        image.columns, image.rows
      )
    end

    def save(path)
      image = Magick::Image.new(columns, rows)
      image.store_pixels(0, 0, columns, rows, pixels)
      image.write(path)
    end
  end
end
