# frozen_string_literal: true

module Jasmine
  module Generators
    class InstallGenerator < Rails::Generators::Base
      class << self
        def source_root
          @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
        end
      end

      def install_jasmine_core
        run 'yarn add --dev jasmine-core'
      end

      def copy_jasmine_files
        directory 'app'
        directory 'config'
        directory 'spec'
      end

      def add_spec_directory_to_resolved_modules
        # This allows Webpack to look for modules starting from the project
        # root in the test environment.  This allows requiring collections of
        # spec modules thusly:
        #
        # require.context('spec/javascript/helpers/', true, /\.js/));
        #
        # If we instead add only the spec directory to resolvedModules then the
        # above would have to load relative to that directory:
        #
        # require.context('javascript/helpers/', true, /\.js/));
        #
        # This lookup may be ambiguous between the app and spec directories,
        # because these two directories should have similar structure.
        #
        # Does adding spec/javascript/helpers and app/javascript/helpers both
        # to the context slow down lookup?  It doesn't seem so, and the
        # intention of the first require line seems more clear.
        content = <<~CONTENT
          environment.resolvedModules.append('project root', '.');
        CONTENT
        append_to_file('config/webpack/environment.js', content)
      end

      def app_name
        Rails.application.class.name
      end
    end
  end
end

