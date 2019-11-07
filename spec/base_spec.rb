# frozen_string_literal: true

require 'spec_helper'

describe Jasmine do
  before do
    class << Rails
      define_method(:root) { '__RAILS_ROOT' }
    end
  end

  after do
    class << Rails
      remove_method(:root)
    end
  end

  it "should provide the root path" do
    allow(File).to receive(:dirname).and_return('lib/jasmine')
    expect(File).to receive(:expand_path) { |path| path }
    expect(Jasmine.root).to eq 'lib/jasmine'
  end

  it "should append passed file paths" do
    allow(File).to receive(:dirname).and_return('lib/jasmine')
    expect(File).to receive(:expand_path) { |path| path }
    expect(Jasmine.root('subdir1', 'subdir2')).to eq File.join('lib/jasmine', 'subdir1', 'subdir2')
  end
end

