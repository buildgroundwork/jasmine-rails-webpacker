# frozen_string_literal: true

require 'action_view'

module Jasmine
  class Page < ActionView::Renderer
    def initialize(extra_js: nil)
      @extra_js = extra_js
      lookup_context = ActionView::LookupContext.new([])
      super(lookup_context)
    end

    def render
      super(view, inline: ::Jasmine.runner_template, layout: nil, locals: { extra_js: extra_js })
    end

    private

    attr_reader :extra_js

    def view
      @view ||= ActionView::Base.with_empty_template_cache.new
    end
  end
end

