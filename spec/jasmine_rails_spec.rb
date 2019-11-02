require 'spec_helper'
require 'net/http'
require 'yaml'
require 'jasmine/ruby_versions'

describe 'A Rails app' do
  def bundle_install
    bundle_output = `NOKOGIRI_USE_SYSTEM_LIBRARIES=true bundle install --path vendor --retry 3;`
    unless $?.success?
      puts bundle_output
      raise "Bundle failed to install."
    end
  end

  def install_webpacker
    # This has to come after the bundle
    output = `rails webpacker:install`
    unless $?.success?
      puts output
      raise "Webpack failed to install."
    end
  end

  before :all do
    temp_dir_before
    Dir::chdir @tmp

    # We want the webpack install, but creating a Rails app with Webpack and
    # the --skip-bundle flag will fail.  So, we'll create the app without
    # Webpack, and then install Webpack after the bundle.
    `rails new rails-example --skip-bundle  --skip-active-record --skip-bootsnap --skip-webpack-install --skip-spring`
    Dir::chdir File.join(@tmp, 'rails-example')

    FileUtils.mkdir_p(File.join(Dir.pwd, 'tmp', 'pids'))

    base = File.absolute_path(File.join(__FILE__, '../..'))
    # Add jasmine to the Gemfile, and update the puma version.
    open('Gemfile', 'a') { |f|
      f.puts "gem 'jasmine', :path => '#{base}'"
      f.puts "gem 'jasmine-core', :git => 'http://github.com/jasmine/jasmine.git'"
      f.flush
    }

    Bundler.with_clean_env do
      bundle_install
      install_webpacker
      `bundle exec rails g jasmine:install`
      expect($?).to eq 0
      expect(File.exists?('spec/javascripts/helpers/.gitkeep')).to eq true
      expect(File.exists?('spec/javascripts/support/jasmine.yml')).to eq true
      `bundle exec rails g jasmine:examples`
      expect(File.exists?('app/assets/javascripts/jasmine_examples/Player.js')).to eq true
      expect(File.exists?('app/assets/javascripts/jasmine_examples/Song.js')).to eq true
      expect(File.exists?('spec/javascripts/jasmine_examples/PlayerSpec.js')).to eq true
      expect(File.exists?('spec/javascripts/helpers/jasmine_examples/SpecHelper.js')).to eq true
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
      FileUtils.cp(File.join(@root, 'spec', 'fixture', 'failing_test.js'), File.join('spec', 'javascripts'))
      failing_yaml = custom_jasmine_config('failing') do |jasmine_config|
        jasmine_config['spec_files'] << 'failing_test.js'
      end

      output = `bundle exec rake jasmine:ci JASMINE_CONFIG_PATH=#{failing_yaml}`
      expect($?).to_not be_success
      expect(output).to include('6 specs, 1 failure')
    end
  end

  it "rake jasmine:ci runs specs when an error occurs in the javascript" do
    Bundler.with_clean_env do
      FileUtils.cp(File.join(@root, 'spec', 'fixture', 'exception_test.js'), File.join('spec', 'javascripts'))
      exception_yaml = custom_jasmine_config('exception') do |jasmine_config|
        jasmine_config['spec_files'] << 'exception_test.js'
      end
      output = `bundle exec rake jasmine:ci JASMINE_CONFIG_PATH=#{exception_yaml}`
      expect($?).to_not be_success
      expect(output).to include('5 specs, 0 failures')
    end
  end
end

