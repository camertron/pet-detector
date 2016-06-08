require 'yaml'

module PetDetector
  class Level
    class << self
      def get(level_num)
        new(level_data[level_num - 1])
      end

      private

      def level_data
        @level_data =
          YAML.load_file(File.expand_path('../levels.yml', __FILE__))['levels']
      end
    end

    attr_reader :data

    def initialize(data)
      @data = data
    end

    def width
      data['width']
    end

    def height
      data['height']
    end

    def animals
      data['animals']
    end
  end
end
