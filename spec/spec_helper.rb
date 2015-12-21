require 'rack/test'
require 'rspec'
require 'factory_girl'
require 'database_cleaner'

ENV['RACK_ENV'] = 'test'
require_relative '../app'

include Rack::Test::Methods
def app() Sinatra::Application end

RSpec.configure do |config|
  config.color = true
  config.tty = true
  # config.formatter = :documentation
  config.include FactoryGirl::Syntax::Methods
  config.before(:suite) do
    begin
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end
end

