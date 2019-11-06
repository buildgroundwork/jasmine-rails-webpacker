module Jasmine
  class YamlConfigParser
    def initialize(path, pwd, path_expander = lambda {}, yaml_loader = lambda {})
      @path = path
      @path_expander = path_expander
      @pwd = pwd
      @yaml_loader = yaml_loader
    end

    def spec_helper
      File.join(@pwd, loaded_yaml['spec_helper'] || File.join('spec', 'javascripts', 'support', 'jasmine_helper.rb'))
    end

    def show_console_log
      loaded_yaml['show_console_log'] || false
    end

    def stop_spec_on_expectation_failure
      loaded_yaml['stop_spec_on_expectation_failure'] || false
    end

    def stop_on_spec_failure
      loaded_yaml['stop_on_spec_failure'] || false
    end

    def random
      if loaded_yaml['random'].nil?
        true
      else
        loaded_yaml['random']
      end
    end

    def rack_options
      loaded_yaml.fetch('rack_options', {}).inject({}) do |memo, (key, value)|
        memo[key.to_sym] = value
        memo
      end
    end

    private
    def loaded_yaml
      @yaml_loader.call(@path)
    end
  end
end
