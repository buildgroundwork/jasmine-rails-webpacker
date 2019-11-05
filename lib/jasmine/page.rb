require 'action_view'

module Jasmine
  class Page < ActionView::Renderer
    def initialize(config)
      @config = config
      lookup_context = ActionView::LookupContext.new([])
      super(lookup_context)
    end

    def render
      super(view, inline: ::Jasmine.runner_template, layout: nil, locals: {
        js_files: config.js_files,
        css_files: config.css_files
      })
    end

    private

    attr_reader :config

    def view
      @view ||= ActionView::Base.with_empty_template_cache.new
    end
  end
end

