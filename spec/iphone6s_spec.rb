require 'spec_helper'
require 'check_entities'

include PetDetector

describe 'iPhone 6s' do
  let!(:manifest) do
    YAML.load_file(
      File.expand_path('../iphone6s/manifest.yml', __FILE__)
    )
  end

  let(:image_path) do
    File.expand_path("../iphone6s/#{image_file}", __FILE__)
  end

  describe 'level14' do
    let(:level) { 12 }

    context 'car_in_the_way' do
      let(:image_file) { 'level14/car_in_the_way.png' }
      include_context :check_entities
    end

    context 'sim1' do
      let(:image_file) { 'level14/sim1.png' }
      include_context :check_entities
    end

    context 'sim2' do
      let(:image_file) { 'level14/sim2.png' }
      include_context :check_entities
    end

    # context 'sim3' do
    #   let(:image_file) { 'level14/sim3.png' }
    #   include_context :check_entities
    # end
  end
end
