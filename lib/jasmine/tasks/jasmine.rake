# frozen_string_literal: true

if Rake.application.tasks.any? { |t| t.name == 'jasmine/ci' }
  message = <<~MSG

                                WARNING
    Detected that jasmine rake tasks have been loaded twice.
    This will cause the 'rake jasmine:ci' and 'rake jasmine' tasks to fail.

    To fix this problem, you should ensure that you only load 'jasmine/tasks/jasmine.rake'
    once. This should be done for you automatically if you installed jasmine's rake tasks
    with either 'jasmine init' or 'rails g jasmine:install'.


  MSG
  raise Exception.new(message)
end

namespace :jasmine do
  task :require_json do
    require 'json'
  rescue LoadError
    puts 'You must have a JSON library installed to run jasmine:ci. Try "gem install json"'
    exit
  end

  task :set_test_env do
    Rails.env = ENV['RAILS_ENV'] = ENV['NODE_ENV'] = 'test'
    # Force Webpacker to reload the instance in test mode.
    Webpacker.instance = nil
  end

  task require: %i[environment set_test_env] do
    require 'jasmine'
  end

  task configure: :require do
    Jasmine.configure!
  end

  task :configure_plugins

  desc 'Run jasmine tests in a browser, random and seed override config'
  task :ci, %i[random seed] => %w(jasmine:require_json jasmine:configure jasmine:configure_plugins) do |_, args|
    ci_runner = Jasmine::CiRunner.new(Jasmine.config, args.to_hash)
    exit(1) unless ci_runner.run
  end

  task server: %w(jasmine:configure jasmine:configure_plugins) do
    config = Jasmine.config
    port = config.port(:server)
    server = Jasmine::Server.new(port, Jasmine::Application.app(Jasmine.config), config.rack_options)
    puts "your server is running here: http://localhost:#{port}/"
    puts ''
    server.start
  end
end

desc 'Start server to host jasmine specs'
task jasmine: %w(jasmine:server)

