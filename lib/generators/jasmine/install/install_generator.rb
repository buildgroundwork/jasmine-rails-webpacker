module Jasmine
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class << self
        def source_root
          @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
        end
      end

      def install_jasmine_core
        run "yarn add --dev jasmine-core"
      end

      def copy_jasmine_files
        directory 'app'
        directory 'spec'
      end

      def copy_webpack_initializer
        destination_file_path = File.join('config', 'initializers', 'webpacker.rb')
        initializer = "Webpacker::Compiler.watched_paths << 'spec/javascripts/**/*.js'"
        if File.exists?(File.expand_path(destination_file_path, destination_root))
          append_to_file(destination_file_path, initializer)
        else
          create_file(destination_file_path, initializer)
        end
      end

      def add_spec_directory_to_resolved_modules
        content = "environment.resolvedModules.append('spec', 'spec');\n"
        inject_into_file('config/webpack/test.js', content, after: /const environment =.*\n/)
      end

      def app_name
        Rails.application.class.name
      end
    end
  end
end
