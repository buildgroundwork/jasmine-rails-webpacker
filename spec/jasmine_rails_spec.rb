# frozen_string_literal: true

require 'spec_helper'
require 'net/http'
require 'english' # for $CHILD_STATUS

describe 'A Rails app' do
  def bundle_install
    bundle_output = `NOKOGIRI_USE_SYSTEM_LIBRARIES=true bundle install --path vendor --retry 3;`
    unless $CHILD_STATUS.success?
      puts bundle_output
      raise "Bundle failed to install."
    end
  end

  def install_webpacker
    # This has to come after the bundle
    output = `rails webpacker:install`
    unless $CHILD_STATUS.success?
      puts output
      raise "Webpack failed to install."
    end
  end

  def install_jasmine
    `bundle exec rails g jasmine:install`
    expect($CHILD_STATUS).to be_success
    expect(File.exist?('spec/javascript/helpers/.gitkeep')).to be_truthy
    expect(File.exist?('spec/javascript/support/jasmine_helper.rb')).to be_truthy
    `bundle exec rails g jasmine:examples`
    expect(File.exist?('app/javascript/jasmine_examples/Player.js')).to be_truthy
    expect(File.exist?('app/javascript/jasmine_examples/Song.js')).to be_truthy
    expect(File.exist?('spec/javascript/jasmine_examples/PlayerSpec.js')).to be_truthy
    expect(File.exist?('spec/javascript/helpers/jasmine_examples/SpecHelper.js')).to be_truthy
  end

  before :all do
    temp_dir_before
    Dir.chdir @tmp

    # We want the webpack install, but creating a Rails app with Webpack and
    # the --skip-bundle flag will fail.  So, we'll create the app without
    # Webpack, and then install Webpack after the bundle.
    `rails new rails-example --skip-bundle  --skip-active-record --skip-bootsnap --skip-webpack-install --skip-spring --skip-turbolinks`
    Dir.chdir File.join(@tmp, 'rails-example')

    FileUtils.mkdir_p(File.join(Dir.pwd, 'tmp', 'pids'))

    # Add this gem to the Gemfile, and update the puma version.
    open('Gemfile', 'a') do |f|
      f.puts "gem 'jasmine-rails-webpacker', :path => '#{File.absolute_path(File.join(__FILE__, '../..'))}'"
      f.flush
    end

    Bundler.with_clean_env do
      bundle_install
      install_webpacker
      install_jasmine
    end
  end

  after :all do
    temp_dir_after
  end

  it 'should have the jasmine & jasmine:ci rake task' do
    Bundler.with_clean_env do
      output = `bundle exec rake -T`
      expect(output).to include('jasmine ')
      expect(output).to include('jasmine:ci')
    end
  end

  it "rake jasmine:ci runs and returns expected results", :focus do
    Bundler.with_clean_env do
      output = `bundle exec rake jasmine:ci`
      expect(output).to include('5 specs, 0 failures')
    end
  end

  it "rake jasmine:ci returns proper exit code when specs fail" do
    Bundler.with_clean_env do
      FileUtils.cp(File.join(@root, 'spec', 'fixture', 'failing_spec.js'), File.join('spec', 'javascript'))

      output = `bundle exec rake jasmine:ci`
      expect($CHILD_STATUS).to_not be_success
      expect(output).to include('6 specs, 1 failure')
    end
  end

  it "rake jasmine:ci runs specs when an error occurs in the javascript" do
    Bundler.with_clean_env do
      FileUtils.cp(File.join(@root, 'spec', 'fixture', 'exception_spec.js'), File.join('spec', 'javascript'))

      `bundle exec rake jasmine:ci`
      expect($CHILD_STATUS).to_not be_success
    end
  end
end

