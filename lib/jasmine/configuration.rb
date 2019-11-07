module Jasmine
  class << self
    def configure!
      config_file = Rails.root.join('spec', 'javascript', 'support', 'jasmine_helper.rb')
      require config_file if File.exists?(config_file)
    end

    def configure(&block)
      block.call(self.config)
    end

    def config
      @config ||= Jasmine::Configuration.new
    end
  end

  class Configuration
    attr_accessor :show_console_log,
      :stop_spec_on_expectation_failure,
      :stop_on_spec_failure,
      :random,
      :show_full_stack_trace

    attr_writer :formatters, :runner

    attr_writer :host,
      :server_port,
      :ci_port,
      :rack_options

    attr_writer :chrome_options

    def initialize
      @random = true
    end

    def formatters
      @formatters ||= [Jasmine::Formatters::Console]
    end

    def runner
      @runner ||= default_runner
    end

    def host
      @host ||= 'http://localhost'
    end

    def port(server_type)
      server_type == :server ? server_port : ci_port
    end

    def rack_options
      @rack_options ||= {}
    end

    def chrome_options
      @chrome_options ||= default_chrome_options
    end

    def add_rack_path(path, rack_app_lambda)
      additional_rack_paths[path] = rack_app_lambda
    end

    def add_rack_app(app, *args, &block)
      additional_rack_apps << { app: app, args: args, block: block }
    end

    def prevent_phantom_js_auto_install=(*)
      ActiveSupport::Deprecation.warn('This gem no longer supports Phantom JS.  No need to call #prevent_phantom_js_auto_install=')
    end

    def use_additional_rack_apps(builder)
      additional_rack_apps.each do |app|
        builder.use(app[:app], *app[:args], &app[:block])
      end
    end

    def map_additional_rack_paths(builder)
      additional_rack_paths.each do |path, handler|
        builder.map(path) { run handler.call }
      end
    end

    private

    def default_runner
      ->(formatter, jasmine_server_url) {
        Jasmine::Runners::ChromeHeadless.new(formatter, jasmine_server_url, self)
      }
    end

    def server_port
      @server_port ||= 8888
    end

    def ci_port
      @ci_port ||= Jasmine.find_unused_port
    end

    def default_chrome_options
      {
        cli: { "no-sandbox" => nil, "headless" => nil, "remote-debugging-port" => 9222 },
        startup_timeout: 3,
        binary: nil
      }
    end

    def additional_rack_paths
      @additional_rack_paths ||= {}
    end

    def additional_rack_apps
      @additional_rack_apps ||= []
    end
  end
end

