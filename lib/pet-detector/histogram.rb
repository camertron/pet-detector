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

    def buckets
      @buckets ||= pixels.each_with_object({}) do |pixel, hist|
        key = [
          ((pixel.red & 255) / variance).round,
          ((pixel.green & 255) / variance).round,
          ((pixel.blue & 255) / variance).round
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
  end
end
