$LOAD_PATH.unshift(File.dirname(__FILE__))

env = ENV['RACK_ENV'].to_sym

require "bundler/setup"
Bundler.require(:default, env)

Dotenv.load if env == :development

# automatically parse json in the body
use Rack::PostBodyContentTypeParser

require_relative 'post'
require_relative 'server'
run Server
