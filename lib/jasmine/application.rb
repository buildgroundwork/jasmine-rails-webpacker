require 'rack'
require 'rack/utils'
require 'rack/jasmine/runner'
require 'rack/jasmine/focused_suite'
require 'rack/jasmine/cache_control'
require 'ostruct'

module Jasmine
  class Application
    class << self
      def app(config, builder = Rack::Builder.new)
        builder.use(Rack::Head)
        builder.use(Rack::Jasmine::CacheControl)

        use_additional_rack_apps(builder, config)

        builder.use(Rack::Static, urls: ['/packs'], root: Rails.application.paths['public'].first)
        builder.map('/') { run Rack::Jasmine::Runner.new(Jasmine::Page.new) }

        map_additional_rack_paths(builder, config)

        builder
      end

      private

      def use_additional_rack_apps(builder, config)
        config.rack_apps.each do |app_config|
          builder.use(app_config[:app], *app_config[:args], &app_config[:block])
        end
      end

      def map_additional_rack_paths(builder, config)
        config.rack_path_map.each do |path, handler|
          builder.map(path) { run handler.call }
        end
      end
    end
  end
end

