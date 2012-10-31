require 'rubygems'
require 'bundler'
Bundler.require

require './lib/5chan'
run Sinatra::Application
