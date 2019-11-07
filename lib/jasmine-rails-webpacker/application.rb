# frozen_string_literal: true

require 'rack'
require 'rack/utils'
require 'rack/jasmine/runner'
require 'rack/jasmine/focused_suite'
require 'rack/jasmine/cache_control'
require 'ostruct'

module Jasmine
  class Application
    class << self
      def app(config, builder: Rack::Builder.new, extra_js: nil)
        builder.use(Rack::Head)
        builder.use(Rack::Jasmine::CacheControl)

        config.use_additional_rack_apps(builder)

        builder.use(Rack::Static, urls: ['/packs'], root: Rails.application.paths['public'].first)
        map_root(builder, extra_js: extra_js)

        config.map_additional_rack_paths(builder)

        builder
      end

      private

      def map_root(builder, extra_js: )
        # Sadly, rubocop can't distinguish between Enumerator#map
        # and Rack::Builder#map
        #
        # rubocop:disable Style/CollectionMethods
        page = Jasmine::Page.new(extra_js: extra_js)
        request_handler = Rack::Jasmine::Runner.new(page)
        builder.map('/') { run request_handler }
        # rubocop:enable Style/CollectionMethods
      end
    end
  end
end

