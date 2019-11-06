require 'action_view'

module Jasmine
  class Page < ActionView::Renderer
    def initialize
      lookup_context = ActionView::LookupContext.new([])
      super(lookup_context)
    end

    def render
      super(view, inline: ::Jasmine.runner_template, layout: nil)
    end

    private

    def view
      @view ||= ActionView::Base.with_empty_template_cache.new
    end
  end
end

