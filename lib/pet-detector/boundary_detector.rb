module PetDetector
  class BoundaryDetector
    X_OFFSET_FACTOR = 0.15  # pct

    # aspect ratio => offset factor (pct)
    Y_OFFSET_FACTORS = {
      0.56 => 0.18,
      0.66 => 0.15
    }

    # aspect ratio => adjustment factor (pct)
    BOUNDS_ADJUSTMENT_FACTORS = {
      0.56 => 0.10,
      0.66 => 0.12
    }

    TRACK_COLOR_RANGE = ColorRange.new(0..35, 0..35, 0..35)
    BG_COLOR_RANGE = ColorRange.new(31..65, 31..65, 31..65)
    PROBE_COUNT = 7

    class << self
      def resize_if_necessary(bmp, rect)
        expanded_rect = expanded_rect_for(bmp, rect)
        return [bmp, rect] if rect == expanded_rect
        puts 'RESIZE IS NECESSARY'

        placement_rect = placement_rect_for(bmp, rect)
        width, height = bmp_dimensions_for(bmp, placement_rect)

        image = Magick::Image.new(width, height)
        image.store_pixels(
          placement_rect.left, placement_rect.top, bmp.columns, bmp.rows, bmp.pixels
        )

        expanded_bmp = Bitmap.new(
          bmp.filename,
          image.get_pixels(0, 0, image.columns, image.rows),
          image.columns, image.rows
        )

        [expanded_bmp, expanded_rect]
      end

      private

      def expanded_rect_for(bmp, orig_rect)
        left, right, top, bottom = orig_rect.to_a

        if right > bmp.columns
          right += (right - bmp.columns)
        end

        if left < 0
          right += left.abs
          left = 0
        end

        if bottom > bmp.rows
          bottom += (bottom - bmp.rows)
        end

        if top < 0
          bottom += top.abs
          top = 0
        end

        Rect.new(left, right, top, bottom)
      end

      def placement_rect_for(bmp, orig_rect)
        left = if orig_rect.left < 0
          orig_rect.left.abs
        else
          0
        end

        top = if orig_rect.top < 0
          orig_rect.top.abs
        else
          0
        end

        Rect.new(left, left + bmp.columns, top, top + bmp.rows)
      end

      def bmp_dimensions_for(bmp, placement_rect)
        width = [bmp.columns, placement_rect.left + placement_rect.width].max
        height = [bmp.rows, placement_rect.top + placement_rect.height].max
        [width, height]
      end
    end

    attr_reader :bitmap

    def initialize(bitmap)
      @bitmap = bitmap
    end

    def get_bounds
      adjust(
        Rect.new(
          probe_left,
          probe_right,
          probe_top,
          probe_bottom
        )
      )
    end

    private

    def aspect_ratio
      ((bitmap.columns.to_f / bitmap.rows) * 100).floor / 100.0
    end

    def x_offset_factor
      X_OFFSET_FACTOR
    end

    def y_offset_factor
      Y_OFFSET_FACTORS.fetch(aspect_ratio) do
        raise StandardError, 'unsupported aspect ratio'
      end
    end

    def bounds_adjustment_factor
      BOUNDS_ADJUSTMENT_FACTORS.fetch(aspect_ratio) do
        raise StandardError, 'unsupported aspect ratio'
      end
    end

    def adjust(rect)
      # the adjustment factor is calculated as a function of width, then used to
      # adjust both width and height
      adjustment = (rect.width * bounds_adjustment_factor).to_i

      Rect.new(
        rect.left - adjustment,
        rect.right + adjustment,
        rect.top - adjustment,
        rect.bottom + adjustment
      )
    end

    def x_offset
      (bitmap.columns * x_offset_factor).round
    end

    def y_offset
      (bitmap.rows * y_offset_factor).round
    end

    def probe_left
      probe_x(x_offset, 1, y_offset, bitmap.rows - y_offset, TRACK_COLOR_RANGE).compact.min
    end

    def probe_right
      probe_x(bitmap.columns - x_offset, -1, y_offset, bitmap.rows - y_offset, TRACK_COLOR_RANGE).compact.max
    end

    def probe_top
      probe_y(y_offset, 1, x_offset, bitmap.columns - x_offset, TRACK_COLOR_RANGE).compact.min
    end

    def probe_bottom
      probe_y(bitmap.rows - y_offset, -1, x_offset, bitmap.columns - x_offset, TRACK_COLOR_RANGE).compact.max
    end

    def probe_y(y_start, y_delta, x_start, x_stop, stop_color)
      width = x_stop - x_start
      x_incr = (width / PROBE_COUNT) - ((width / PROBE_COUNT) / 2)
      x_cur = x_start

      PROBE_COUNT.times.map do
        x, y = probe(x_cur, y_start, 0, y_delta, stop_color)
        x_cur += x_incr
        y
      end
    end

    def probe_x(x_start, x_delta, y_start, y_stop, stop_color)
      height = y_stop - y_start
      y_incr = (height / PROBE_COUNT) - ((height / PROBE_COUNT) / 2)
      y_cur = y_start

      PROBE_COUNT.times.map do
        x, y = probe(x_start, y_cur, x_delta, 0, stop_color)
        y_cur += y_incr
        x
      end
    end

    def probe(x_start, y_start, x_delta, y_delta, stop_color)
      x = x_start
      y = y_start

      loop do
        break nil unless bitmap.in_bounds?(x, y)
        break x, y if stop_color.include?(bitmap[x, y])
        x += x_delta
        y += y_delta
      end
    end
  end
end
