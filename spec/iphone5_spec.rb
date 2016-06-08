require 'spec_helper'
require 'check_entities'

include PetDetector

describe 'iPhone 5' do
  let!(:manifest) do
    YAML.load_file(
      File.expand_path('../iphone5/manifest.yml', __FILE__)
    )
  end

  let(:image_path) do
    File.expand_path("../iphone5/#{image_file}", __FILE__)
  end

  describe 'level12' do
    let(:level) { 12 }

    context 'sim1' do
      let(:image_file) { 'level12/sim1.png' }
      include_context :check_entities
    end
  end

  describe 'level11' do
    let(:level) { 11 }

    context 'sim1' do
      let(:image_file) { 'level11/sim1.png' }
      include_context :check_entities
    end
  end

  describe 'level8' do
    let(:level) { 8 }

    context 'sally' do
      let(:image_file) { 'level8/sally.jpg' }
      include_context :check_entities
    end
  end

  describe 'level5' do
    let(:level) { 5 }

    context 'sim1' do
      let(:image_file) { 'level5/sim1.png' }
      include_context :check_entities
    end
  end
end
