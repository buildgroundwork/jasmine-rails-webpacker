require 'spec_helper'
require 'net/http'
require 'yaml'
require 'jasmine/ruby_versions'

if rails_available?
  describe 'A Rails app' do
    def bundle_install
      bundle_output = `NOKOGIRI_USE_SYSTEM_LIBRARIES=true bundle install --path vendor --retry 3;`
      unless $?.success?
        puts bundle_output
        raise "Bundle failed to install."
      end
    end

    before :all do
      temp_dir_before
      Dir::chdir @tmp

      `rails new rails-example --skip-bundle  --skip-active-record --skip-bootsnap --skip-webpack-install`
      Dir::chdir File.join(@tmp, 'rails-example')

      base = File.absolute_path(File.join(__FILE__, '../..'))

      open('Gemfile', 'a') { |f|
        f.puts "gem 'jasmine', :path => '#{base}'"
        f.puts "gem 'jasmine-core', :git => 'http://github.com/jasmine/jasmine.git'"
        f.flush
      }

      Bundler.with_clean_env do
        bundle_install
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
      #See https://github.com/jimweirich/rake/issues/220 and https://github.com/jruby/activerecord-jdbc-adapter/pull/467
      #There's a workaround, but requires setting env vars & jruby opts (non-trivial when inside of a jruby process), so skip for now.
      Bundler.with_clean_env do
        output = `bundle exec rake -T`
        expect(output).to include('jasmine ')
        expect(output).to include('jasmine:ci')
      end
    end

    describe "with Chrome headless" do
      before :all do
        open('spec/javascripts/support/jasmine_helper.rb', 'w') { |f|
          f.puts "Jasmine.configure do |config|\n  config.runner_browser = :chromeheadless\nend\n"
          f.flush
        }
        Bundler.with_clean_env do
          `bundle add chrome_remote`
        end
      end

      after :all do
        Bundler.with_clean_env do
          `bundle remove chrome_remote`
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

    def run_jasmine_server(options = "")
      Bundler.with_clean_env do
        begin
          pid = IO.popen("bundle exec rake jasmine #{options}").pid
          Jasmine::wait_for_listener(8888, 'localhost', 60)

          # if the process we started is not still running, it's very likely this test
          # will fail because another server is already running on port 8888
          # (kill -0 will check if you can send *ANY* signal to this process)
          # (( it does not actually kill the process, that happens below))
          `kill -0 #{pid}`
          unless $?.success?
            puts "someone else is running a server on port 8888"
            expect($?).to be_success
          end
          yield
        ensure
          Process.kill(:SIGINT, pid)
          begin
            Process.waitpid pid
          rescue Errno::ECHILD
          end
        end
      end
    end
  end
end
