require 'rubygems'
require 'bundler'
require 'securerandom'
require 'sinatra/namespace'
Bundler.require(:default)

# Load the user model
require_relative 'model/users'
register Sinatra::Namespace


# Configure the mongo client
configure do
  if ENV['RACK_ENV'].eql? 'production'
    Mongoid.load!("config/mongoid.yml", :production)
  else
    Mongoid.load!("config/mongoid.yml", :development)
  end
end

# the routes

namespace '/api' do
  post '/login' do
    data = JSON.parse(request.body.read)
    user = Users.authentication(data)
    user.to_json
  end

  post '/signup' do
    data = JSON.parse(request.body.read)
    user = Users.new(data)
    user.save
    status 201
    user.to_json
  end

  get '/reset_password' do
    data = JSON.parse(request.body.read)
    user = Users.reset_password(data)

  end

  before(:each) do
    data = JSON.parse(request.body.read)
    Users.check_token(data[:auth_token])
  end

  get '/users' do
      Users.all.to_json
    end

  get '/users/:id' do
    users = Users.find(params[:id])
    return status 404 if Users.nil?
    users.to_json
  end


  put '/users/:id' do
    users = Users.find(params[:id])
    return status 404 if users.nil?
    data = JSON.parse(request.body.read)
    users.update(data)
    users.save
    status 202
    users.to_json
  end

  delete '/users/:id' do
    users = Users.find(params[:id])
    return status 404 if users.nil?
    users.delete
    status 202
  end
end
