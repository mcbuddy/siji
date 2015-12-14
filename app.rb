require 'rubygems'
require 'bundler'
require 'securerandom'
Bundler.require(:default)

# Load the user model
require_relative 'model/users'

# Configure the mongo client
configure do
  Mongoid.load!("config/database.yml", :development)
end

# the routes
post '/login' do
  data = JSON.parse(request.body.read)
  user = Users.authentication(data)
  user.to_json
end

get '/users' do
  Users.all.to_json
end

get '/users/:id' do
  users = Users.find(params[:id])
  return status 404 if Users.nil?
  users.to_json
end

post '/users' do
  data = JSON.parse(request.body.read)
  users = Users.new(data)
  users.save
  status 201
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



