require 'spec_helper'
require 'check_entities'

include PetDetector

describe 'iPhone 6' do
  let!(:manifest) do
    YAML.load_file(
      File.expand_path('../iphone6/manifest.yml', __FILE__)
    )
  end

  let(:image_path) do
    File.expand_path("../iphone6/#{image_file}", __FILE__)
  end

  describe 'level12' do
    let(:level) { 12 }

    context 'real_deal' do
      let(:image_file) { 'level12/real_deal.jpg' }
      include_context :check_entities
    end

    context 'real_deal2' do
      let(:image_file) { 'level12/real_deal2.jpg' }
      include_context :check_entities
    end

    context 'real_deal3' do
      let(:image_file) { 'level12/real_deal3.jpg' }
      include_context :check_entities
    end

    context 'sim1' do
      let(:image_file) { 'level12/sim1.jpg' }
      include_context :check_entities
    end

    context 'sim2' do
      let(:image_file) { 'level12/sim2.jpg' }
      include_context :check_entities
    end

    context 'sim3' do
      let(:image_file) { 'level12/sim3.jpg' }
      include_context :check_entities
    end

    context 'sim4' do
      let(:image_file) { 'level12/sim4.jpg' }
      include_context :check_entities
    end

    context 'sim5' do
      let(:image_file) { 'level12/sim5.jpg' }
      include_context :check_entities
    end
  end
end
