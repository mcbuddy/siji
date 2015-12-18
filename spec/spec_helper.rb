require 'rack/test'
require 'rspec'
require 'factory_girl'

ENV['RACK_ENV'] = 'test'
require_relative '../app'

include Rack::Test::Methods
def app() Sinatra::Application end

RSpec.configure do |config|
  config.color = true
  config.tty = true
  config.formatter = :documentation
end