# -*- encoding: utf-8 -*-

$:.push File.expand_path("../lib", __FILE__)
require "jasmine-rails-webpacker/version"

Gem::Specification.new do |s|
  s.name               = %q{jasmine-rails-webpacker}
  s.version            = JasmineRailsWebpacker::VERSION
  s.platform           = Gem::Platform::RUBY
  s.required_ruby_version = '>= 2.3'

  s.authors            = ['Adam Milligan', 'Rajan Agaskar', 'Gregg Van Hove']
  s.summary            = %q{JavaScript BDD framework}
  s.description        = %q{Test your JavaScript with a nice descriptive syntax in Rails with Webpacker.}
  s.email              = %q{social@buildgroundwork.com}
  s.homepage           = "https://buildgroundwork.com"
  s.license            = "MIT"

  s.files              = `git ls-files`.split("\n") | Dir.glob('jasmine-rails-webpacker/**/*')
  s.test_files         = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables        = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths      = ["lib"]
  s.rdoc_options       = ["--charset=UTF-8"]

  # Rails 6 only
  s.add_dependency 'rails', '>= 6', '< 7.0.0'
  s.add_dependency 'webpacker'
  s.add_dependency 'chrome_remote'

  s.add_development_dependency 'multi_json'
  s.add_development_dependency 'rspec', '>= 2.5.0'
  s.add_development_dependency 'rubocop'
end

