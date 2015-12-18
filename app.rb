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
  def validate_user(request)
    data = JSON.parse(request.body.read)
    Users.check_token(data['auth_token'])
    true
  end

  post '/login' do
    data = JSON.parse(request.body.read)
    user = Users.authentication(data)
    user.to_json
  end

  post '/signup' do
    data = JSON.parse(request.body.read)
    user = Users.new(data)
    user.save
    res = Users.send_email_registration(user)
    return res.to_json
    status 201
  end

  get '/reset_password' do
    data = JSON.parse(request.body.read)
    Users.reset_password(data['email'])
  end

  get '/users' do
    valid = validate_user(request)
    if valid.eql? true
      return Users.all.to_json
    end
  end

  get '/users/:id' do
    valid = validate_user(request)
    if valid.eql? true
      users = Users.find(params[:id])
      return status 404 if Users.nil?
      users.to_json
    end
  end


  put '/users/:id' do
    valid = validate_user(request)
    if valid.eql? true
      users = Users.find(params[:id])
      return status 404 if users.nil?
      data = JSON.parse(request.body.read)
      users.update(data)
      users.save
      status 202
      users.to_json
    end
  end

  delete '/users/:id' do
    valid = validate_user(request)
    if valid.eql? true
      users = Users.find(params[:id])
      return status 404 if users.nil?
      users.delete
      status 202
    end
  end
end
