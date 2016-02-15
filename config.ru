$stdout.sync = true # enables printing to the console

require 'rubygems'
require 'bundler'
Bundler.require

require './web.rb'
run Sinatra::Application
