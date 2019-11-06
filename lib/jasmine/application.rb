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

        config.use_additional_rack_apps(builder)

        builder.use(Rack::Static, urls: ['/packs'], root: Rails.application.paths['public'].first)
        builder.map('/') { run Rack::Jasmine::Runner.new(Jasmine::Page.new) }

        config.map_additional_rack_paths(builder)

        builder
      end
    end
  end
end

