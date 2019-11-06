require 'spec_helper'

describe 'Jasmine::Application' do
  let(:config) { double(:config, use_additional_rack_apps: nil, map_additional_rack_paths: nil) }
  let(:builder) { double(:builder, use: nil, map: nil) }
  let(:paths) { { 'public' => %w(foo bar) } }
  before do
    rails_application = double(:application, paths: paths)
    Rails.singleton_class.class_eval do
      define_method(:application) { rails_application }
    end
  end

  after do
    class << Rails
      remove_method(:application)
    end
  end

  describe ".app" do
    subject { -> { Jasmine::Application.app(config, builder) } }

    it "should return the builder" do
      expect(subject.call).to eq(builder)
    end

    it "should use any additional rack apps from the config" do
      subject.call
      expect(config).to have_received(:use_additional_rack_apps).with(builder)
    end

    it "should map any additional rack paths from the config" do
      subject.call
      expect(config).to have_received(:map_additional_rack_paths).with(builder)
    end

    it "should insert handler for static assets served from the 'packs' directory" do
      subject.call
      expect(builder).to have_received(:use).with(Rack::Static, urls: ['/packs'], root: paths['public'].first)
    end
  end
end

