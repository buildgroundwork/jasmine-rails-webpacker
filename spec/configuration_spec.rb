# frozen_string_literal: true

require 'spec_helper'

describe Jasmine::Configuration do
  let(:config) { described_class.new }

  describe "#use_additional_rack_apps" do
    subject { -> { config.use_additional_rack_apps(builder) } }
    let(:builder) { double(:builder, use: nil, map: nil) }

    context "with a custom app in the config" do
      let(:rack_app) { double(:rack_app) }

      context "specified with no args" do
        before { config.add_rack_app(rack_app) }

        it "should use the specified app" do
          subject.call
          expect(builder).to have_received(:use).with(rack_app)
        end
      end

      context "specified with args" do
        let(:app_args) { %i(foo, bar) }
        before { config.add_rack_app(rack_app, *app_args) }

        it "should use the specified app" do
          subject.call
          expect(builder).to have_received(:use) do |*used_args, &arg_block|
            used_args == [rack_app, *app_args] && arg_block == nil
          end
        end
      end

      context "specified with args and a block" do
        let(:app_args) { %i(foo, bar) }
        let(:app_block) { -> { true } }
        before { config.add_rack_app(rack_app, *app_args) }

        it "should use the specified app" do
          subject.call
          expect(builder).to have_received(:use) do |*used_args, &arg_block|
            used_args == [rack_app, *app_args] && arg_block == app_block
          end
        end
      end
    end
  end

  describe "#map_additional_rack_paths" do
    subject { -> { config.map_additional_rack_paths(builder) } }
    let(:builder) { double(:builder, use: nil, map: nil) }

    context "with a custom path in the config" do
      let(:path) { '/foo' }
      let(:handler_proc) { -> { handler } }
      let(:handler) { double(:handler) }
      before { config.add_rack_path(path, handler_proc) }

      it "should map the custom path" do
        subject.call
        expect(builder).to have_received(:map) do |mapped_path, mapped_proc|
          path == mapped_path && handler_proc == mapped_proc
        end
      end
    end
  end

  describe '#host' do
    subject { config.host }

    context "when explicitly set" do
      let(:new_host) { 'http://example.com' }
      before { config.host = new_host }
      it { should == new_host }
    end

    context "when not explicitly set" do
      it { should == 'http://localhost' }
    end
  end

  describe "#port" do
    subject { config.port(type) }

    context "with type == :server" do
      let(:type) { :server }

      context "when the server port has been explicitly set" do
        let(:new_port) { 666 }
        before { config.server_port = 666 }
        it { should == new_port }
      end

      context "when the server port has not been explicitly set" do
        it { should == 8888 }
      end
    end

    context "with type == :ci" do
      let(:type) { :ci }

      context "when the CI port has been explicitly set" do
        let(:new_port) { 777 }
        before { config.ci_port = 777 }
        it { should == new_port }
      end

      context "when the CI port has not been explicitly set" do
        let(:random_ports) { [1234, 5678] }
        before { allow(Jasmine).to receive(:find_unused_port).and_return(*random_ports) }

        it { should == random_ports.first }

        context "when called multiple times" do
          before { config.port(:ci) }
          it { should == random_ports.first }
        end
      end
    end
  end

  describe "#formatters" do
    subject { config.formatters }

    context "when explicitly set" do
      let(:new_formatter) { double(:formatter) }
      before { config.formatters = [new_formatter] }
      it { should == [new_formatter] }
    end

    context "when not explicitly set" do
      it { should == [Jasmine::Formatters::Console] }
    end
  end

  describe "#runner" do
    subject { config.runner }

    context "when explicitly set" do
      let(:new_runner) { double(:runner) }
      before { config.runner = new_runner }
      it { should == new_runner }
    end

    context "when not explicitly set" do
      it "should default to a proc that returns a ChromeHeadless runner instance" do
        runner = subject.call('formatter', 'url')
        expect(runner).to be_a(Jasmine::Runners::ChromeHeadless)
      end
    end
  end
end

