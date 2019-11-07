# frozen_string_literal: true

module Jasmine
  class CiRunner
    def initialize(
      config,
      thread: Thread,
      application_factory: Jasmine::Application,
      server_factory: Jasmine::Server,
      outfile: $stdout,
      **url_options
    )
      @config = config
      @thread_class = thread
      @application_factory = application_factory
      @server_factory = server_factory
      @outfile = outfile

      build_url(**url_options)
    end

    def run
      start_server
      runner.run

      exit_code_formatter.succeeded?
    end

    private

    attr_reader :config, :url

    def start_server
      server = @server_factory.new(config.port(:ci), app, config.rack_options)

      thread = @thread_class.new { server.start }
      thread.abort_on_exception = true

      Jasmine.wait_for_listener(config.port(:ci), config.host.sub(%r(\Ahttps?://), ''))
      @outfile.puts 'jasmine server started'
    end

    def build_url(options)
      random = options.fetch(:random, config.random)
      seed = options.has_key?(:seed) ? "&seed=#{options[:seed]}" : ''
      @url = "#{config.host}:#{config.port(:ci)}/?throwFailures=#{config.stop_spec_on_expectation_failure}&failFast=#{config.stop_on_spec_failure}&random=#{random}#{seed}"
    end

    def runner
      @runner ||= config.runner.call(Jasmine::Formatters::Multi.new(formatters), url)
    end

    def formatters
      @formatters ||= config.formatters.collect(&:new) << exit_code_formatter
    end

    def exit_code_formatter
      @exit_code_formatter ||= Jasmine::Formatters::ExitCode.new
    end

    def app
      @application_factory.app(config, extra_js: runner.boot_js)
    end
  end
end

