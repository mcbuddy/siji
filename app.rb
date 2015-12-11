require 'rubygems'
require 'bundler'
Bundler.require(:default)

# Load the user model
require_relative 'model/users'

# Configure the mongo client
configure do
  Mongoid.load!("config/database.yml", :development)
end


# the routes
get '/users' do
  Users.all.to_json
end

get '/users/:id' do
  users = Users.find(params[:id])
  return status 404 if Users.nil?
  users.to_json
end

post '/users' do
  users = Users.new(params['users'])
  users.save
  status 201
  users.to_json
end

put '/users/:id' do
  users = Users.find(params[:id])
  return status 404 if users.nil?
  users.update(params[:users])
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