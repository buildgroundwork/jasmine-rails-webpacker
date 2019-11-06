module Jasmine
  class Configuration
    attr_accessor :formatters
    attr_accessor :host
    attr_accessor :spec_format
    attr_writer :runner
    attr_accessor :rack_options
    attr_accessor :show_console_log
    attr_accessor :stop_spec_on_expectation_failure
    attr_accessor :stop_on_spec_failure
    attr_accessor :random
    attr_accessor :chrome_cli_options
    attr_accessor :chrome_startup_timeout
    attr_accessor :chrome_binary
    attr_accessor :show_full_stack_trace
    attr_reader :rack_apps

    def initialize
      @rack_paths = {}
      @rack_apps = []
      @rack_options = {}
      @show_console_log = false
      @stop_spec_on_expectation_failure = false
      @stop_on_spec_failure = false
      @random = true
      @chrome_cli_options = {"no-sandbox" => nil, "headless" => nil, "remote-debugging-port" => 9222}
      @chrome_startup_timeout = 3
      @chrome_binary = nil

      @formatters = [Jasmine::Formatters::Console]

      @server_port = 8888
    end

    def runner
      @runner ||= default_runner
    end

    def prevent_phantom_js_auto_install=(*)
      ActiveSupport::Deprecation.warn('This gem no longer supports Phantom JS.  No need to call #prevent_phantom_js_auto_install=')
    end

    def rack_path_map
      {}.merge(@rack_paths)
    end

    def add_rack_path(path, rack_app_lambda)
      @rack_paths[path] = rack_app_lambda
    end

    def add_rack_app(app, *args, &block)
      @rack_apps << { app: app, args: args, block: block }
    end

    def server_port=(port)
      @server_port = port
    end

    def ci_port=(port)
      @ci_port = port
    end

    def port(server_type)
      if server_type == :server
        @server_port
      else
        @ci_port ||= Jasmine.find_unused_port
      end
    end

    def host
      @host || 'http://localhost'
    end

    private

    def default_runner
      ->(formatter, jasmine_server_url) {
        Jasmine::Runners::ChromeHeadless.new(formatter, jasmine_server_url, self)
      }
    end
  end
end

