require 'spec_helper'
require 'check_entities'

include PetDetector

describe 'iPhone 4' do
  let!(:manifest) do
    YAML.load_file(
      File.expand_path('../iphone4/manifest.yml', __FILE__)
    )
  end

  let(:image_path) do
    File.expand_path("../iphone4/#{image_file}", __FILE__)
  end

  describe 'level12' do
    let(:level) { 12 }

    context 'sim1' do
      let(:image_file) { 'level12/sim1.png' }
      include_context :check_entities
    end

    context 'sim2' do
      let(:image_file) { 'level12/sim2.png' }
      include_context :check_entities
    end

    context 'sim3' do
      let(:image_file) { 'level12/sim3.png' }
      include_context :check_entities
    end
  end

  describe 'level5' do
    let(:level) { 5 }

    context 'sim1' do
      let(:image_file) { 'level5/sim1.png' }
      include_context :check_entities
    end

    context 'sim2' do
      let(:image_file) { 'level5/sim2.png' }
      include_context :check_entities
    end
  end

  describe 'level3' do
    let(:level) { 3 }

    context 'sim1' do
      let(:image_file) { 'level3/sim1.png' }
      include_context :check_entities
    end
  end
end
