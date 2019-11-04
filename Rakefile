$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/lib")
require 'bundler'
Bundler::GemHelper.install_tasks

require 'jasmine'
require 'rspec'
require 'rspec/core/rake_task'

desc 'Run all examples'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = '-t ~performance'
end

desc 'Run performance build'
RSpec::Core::RakeTask.new(:performance_specs) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = '-t performance'
end

task :default => :spec

