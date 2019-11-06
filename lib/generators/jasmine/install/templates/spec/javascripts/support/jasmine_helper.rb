# Use this file to set/override Jasmine configuration options
# You can remove it if you don't need it.
#
Jasmine.configure do |config|
=begin
  # Default values
  config.show_console_log = false
  config.stop_spec_on_expectation_failure = false
  config.stop_on_spec_failure = false
  config.random = true
=end

=begin
  # Options for running from the command line.

  # Set the formatters for the spec run.  Defaults to console output.
  config.formatters = [My::Custom::Formatter]
  # OR
  config.formatters << My::Custom::Formatter

  # Set the runner.  Defaults to the Chrome Headless runner.
  config.runner = My::Custom::Runner

  # Set the port.  Defaults to a random open port.
  config.ci_port = 1234

  # Show stack traces for failures.  Defaults to false.
  config.show_full_stack_trace = true
=end

=begin
  # Options for running in the browser

  # Defaults to "http://localhost"
  config.host = 'http://my.host'

  # Set the browser port.  Defaults to 8888.
  config.server_port = 7777
=end

=begin
  # Options for customizing Jasmine's Rack stack.

  # Add extra Rack apps for the Racker builder to use.
  config.add_rack_app(Rack::Wibble, this: 1, that: 2, &block)

  # Add extra paths for Rack to map.  The second argument must be a callable
  # object that returns a handler that Rack can run.
  config.app_rack_path('/', -> { Rack::Custom.new })

  # Extra options to be passed to the rack server by default, Port and AccessLog
  # are passed.
  #
  # This is an advanced option, and left empty by default.
  #
  # Example:
  # config.rack_options = { server: 'thin' }
  config.rack_options = {}
=end

=begin
  # Extra options for customizing the Chrome Headless runtime.
  #   cli: Settings to customize the CLI.
  #   startup_timeout: Change the amount of time to wait for chrome to start.
  #   binary: Which binary to execute.
  #
  # This is an advanced option; you should know what you're doing.
  config.chrome_options = {
    cli: { "no-sandbox" => nil, "headless" => nil, "remote-debugging-port" => 9222 },
    startup_timeout: 3,
    binary: nil
  }
=end
end

