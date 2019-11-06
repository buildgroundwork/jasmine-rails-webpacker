require 'spec_helper'

describe 'Jasmine::Application' do
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

  it 'should map paths provided by the config' do
    handler1 = double(:handler1)
    handler2 = double(:handler2)
    app1 = double(:app1)
    app2 = double(:app2)
    rack_path_map = {'/foo' => lambda { handler1 }, '/bar' => lambda { handler2 }}
    config = double(:config, :rack_path_map => rack_path_map, :rack_apps => [])
    builder = double('Rack::Builder.new', use: nil, map: nil)
    #Rack::Builder instance evals, so builder.run is invalid syntax,
    #this is the only way to stub out the 'run' dsl it gives to the block.
    allow(Jasmine::Application).to receive(:run).with(handler1).and_return(app1)
    allow(Jasmine::Application).to receive(:run).with(handler2).and_return(app2)

    expect(builder).to receive(:map).thrice do |path, &app|
      path == '/' ||
        path == '/foo' && app.call == app1 ||
        path == '/bar' && app.call == app2
    end

    expect(Jasmine::Application.app(config, builder)).to eq builder
  end

  it 'should run rack apps provided by the config' do
    app1 = double(:app1)
    app2 = double(:app2)
    app3 = double(:app3)
    app4 = double(:app4)
    block = lambda { 'foo' }
    config = double(:config, :rack_path_map => [], :rack_apps => [
        { :app => app1 },
        { :app => app2, :block => block },
        { :app => app3, :args => [:foo, :bar], :block => block },
        { :app => app4, :args => [:bar] }
    ])
    builder = double('Rack::Builder.new', use: nil, map: nil)

    expect(builder).to receive(:use).with(app1)
    expect(builder).to receive(:use) do |*args, &arg_block|
      args == [app2] && arg_block == block
    end
    expect(builder).to receive(:use) do |*args, &arg_block|
      args == [app3, :foo, :bar] && arg_block == block
    end
    expect(builder).to receive(:use).with(app4, :bar)
    expect(Jasmine::Application.app(config, builder)).to eq builder
  end

  it "should insert handler for static assets served from the 'packs' directory" do
    builder = double('Rack::Builder.new', use: nil, map: nil)
    config = double(:config, :rack_path_map => [], :rack_apps => [])
    expect(builder).to receive(:use).with(Rack::Static, urls: ['/packs'], root: paths['public'].first)
    Jasmine::Application.app(config, builder)
  end
end

