ENV['RACK_ENV'] = 'test'

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require 'minitest/autorun'
require 'rack/test'