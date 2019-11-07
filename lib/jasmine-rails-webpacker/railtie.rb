# frozen_string_literal: true

require 'rails/railtie'

module Jasmine
  class Railtie < Rails::Railtie
    initializer 'jasmine.initializer', before: :load_environment_hook do
      old_jasmine_rakefile = ::Rails.root.join('lib', 'tasks', 'jasmine.rake')
      if old_jasmine_rakefile.exist? && !ENV['USE_JASMINE_RAKE']
        $stdout.puts <<~MSG
          You no longer need to have jasmine.rake in your project, as it is now automatically loaded
          from the Jasmine gem. To silence this warning, set "USE_JASMINE_RAKE=true" in your environment
          or remove jasmine.rake.
        MSG
      end
    end

    rake_tasks do
      load 'jasmine-rails-webpacker/tasks/jasmine.rake'
    end
  end
end

