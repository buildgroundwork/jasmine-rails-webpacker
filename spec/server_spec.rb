# frozen_string_literal: true

require 'spec_helper'

describe Jasmine::Server do
  before do
    Rack::Server = double("Rack::Server") unless Rack.constants.include?(:Server)
    @fake_env = {}
  end

  it "should start the server" do
    expect(Rack::Server).to receive(:start) { double(:server).as_null_object }
    Jasmine::Server.new('8888', double(:app), nil, @fake_env).start
  end

  it "should pass rack options when starting the server" do
    app = double('application')
    expect(Rack::Server).to receive(:start).with(hash_including(app: app, Port: 1234, foo: 'bar')).and_return(double(:server).as_null_object)
    Jasmine::Server.new(1234, app, { foo: 'bar', Port: 4321 }, @fake_env).start
    expect(@fake_env['PORT']).to eq('1234')
  end
end

