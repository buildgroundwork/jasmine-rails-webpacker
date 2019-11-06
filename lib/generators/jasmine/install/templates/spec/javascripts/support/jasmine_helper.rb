# Use this file to set/override Jasmine configuration options
# You can remove it if you don't need it.
#
Jasmine.configure do |config|
=begin
  # Default values
  config.show_console_log = false
  config.stop_spec_on_expectation_failure = false
  config.stop_on_spec_failure = false
  config.random = true
=end

=begin
  # Extra options to be passed to the rack server
  # by default, Port and AccessLog are passed.
  #
  # This is an advanced option, and left empty by default.
  #
  # EXAMPLE
  #
  # config.rack_options = { server: 'thin' }
  config.rack_options = {}
=end
end

