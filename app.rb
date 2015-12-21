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
  case ENV['RACK_ENV']
    when 'production'
      Mongoid.load!("config/mongoid.yml", :production)
    when'development'
      Mongoid.load!("config/mongoid.yml", :development)
    when 'test'
      Mongoid.load!("config/mongoid.yml", :test)
  end
end

# the routes
get '/' do
  File.read(File.join('public', 'index.html'))
end

namespace '/api' do
  def validate_user(headers)
    if headers['AUTH-TOKEN'].nil?
      response = {success: false, code: 403 }
      return response.to_json
    else
      token = Users.check_token(headers['AUTH-TOKEN'])
      return true if token.eql true
    end
  end

  post '/login' do
    puts headers
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
    puts headers['AUTH-TOKEN']
    valid = validate_user(headers)
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
