# frozen_string_literal: true

[
  'base',
  'configuration',
  'application',
  'server',
  'page',
  'result',
  'ci_runner',
  File.join('formatters', 'exit_code'),
  File.join('formatters', 'console'),
  File.join('formatters', 'multi'),
  File.join('runners', 'chrome_headless'),
  'railtie'
].each do |file|
  require File.join('jasmine-rails-webpacker', file)
end

