module Jasmine
  ConfigNotFound = Class.new(Exception)
  require 'yaml'
  require 'erb'

  class << self
    def configure(&block)
      block.call(self.config)
    end

    def config
      @config ||= Jasmine::Configuration.new
    end

    def load_configuration_from_yaml(path = nil)
      path ||= File.join(Dir.pwd, 'spec', 'javascripts', 'support', 'jasmine.yml')
      if File.exist?(path)
        yaml_loader = lambda do |filepath|
          YAML::load(ERB.new(File.read(filepath)).result(binding)) if File.exist?(filepath)
        end
        yaml_config = Jasmine::YamlConfigParser.new(path, Dir.pwd, Jasmine::PathExpander.method(:expand), yaml_loader)
        Jasmine.configure do |config|
          config.show_console_log = yaml_config.show_console_log
          config.stop_spec_on_expectation_failure = yaml_config.stop_spec_on_expectation_failure
          config.stop_on_spec_failure = yaml_config.stop_on_spec_failure
          config.random = yaml_config.random

          config.rack_options = yaml_config.rack_options
        end
        require yaml_config.spec_helper if File.exist?(yaml_config.spec_helper)
      else
       raise ConfigNotFound, "Unable to load jasmine config from #{path}"
      end
    end
  end
end

