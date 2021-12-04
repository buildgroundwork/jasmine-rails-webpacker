# frozen_string_literal: true

require 'action_view'

module Jasmine
  class Page < ActionView::Renderer
    def initialize(extra_js: nil)
      @extra_js = extra_js
      @lookup_context = ActionView::LookupContext.new([])
      super(lookup_context)
    end

    def render
      super(view, inline: ::Jasmine.runner_template, layout: nil, locals: { extra_js: extra_js })
    end

    private

    attr_reader :lookup_context, :extra_js

    def view
      # Pass missing default arguments that are required for rails 6+
      @view ||= ActionView::Base.with_empty_template_cache.new(lookup_context, [], nil)
    end
  end
end

