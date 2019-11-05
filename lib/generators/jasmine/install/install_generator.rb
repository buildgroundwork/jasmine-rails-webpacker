module Jasmine
  module Generators
    class InstallGenerator < Rails::Generators::Base

      def self.source_root
        @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
      end

      def install_jasmine_core
        run "yarn add --dev jasmine-core"
      end

      def copy_jasmine_files
        directory 'app'
        directory 'spec'
      end

      def app_name
        Rails.application.class.name
      end
    end
  end
end
