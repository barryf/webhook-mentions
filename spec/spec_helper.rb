$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))

require 'post'
require 'rspec'

ENV['RACK_ENV'] = 'test'
