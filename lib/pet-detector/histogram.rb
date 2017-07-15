module PetDetector
  class Histogram
    attr_reader :pixels, :variance

    def initialize(pixels, variance = 1)
      @pixels = pixels
      @variance = variance
    end

    def reject_color(color_range)
      Histogram.new(
        pixels.reject do |pixel|
          color_range.include?(pixel)
        end,
        variance
      )
    end

    def reject
      Histogram.new(
        pixels.reject { |pixel| yield pixel }, variance
      )
    end

    def reject_gray
      reject { |p| p.red == p.green && p.green == p.blue }
    end

    def buckets
      @buckets ||= pixels.each_with_object({}) do |pixel, hist|
        red = pixel.red & 255
        green = pixel.green & 255
        blue = pixel.blue & 255

        key = [
          red - (red % variance),
          green - (green % variance),
          blue - (blue % variance)
        ]

        hist[key] ||= 0
        hist[key] += 1
      end
    end

    def compare(other_hist)
      # chi-square algorithm
      # http://www.itl.nist.gov/div898/handbook/eda/section3/eda35f.htm
      # http://stats.stackexchange.com/questions/184101/comparing-two-histograms-using-chi-square-distance
      other_hist.buckets.inject(0.0) do |sum, (pixel, expected_freq)|
        # next sum unless buckets.include?(pixel)
        observed_freq = (buckets[pixel] || 0).to_f
        sum + ((observed_freq - expected_freq) ** 2) / (expected_freq + observed_freq)
      end
    end

    def pct_gray
      gray_count = 0.0
      total_count = 0.0

      buckets.each_pair do |bucket, count|
        gray_count += count if bucket[0] == bucket[1] && bucket[1] == bucket[2]
        total_count += count
      end

      gray_count / total_count
    end
  end
end
